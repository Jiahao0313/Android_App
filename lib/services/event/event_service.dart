import "dart:io";

import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";

class EventService {
  static Future<List<Event>> getUpcomingEvents() async {
    final List<Event> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db
          .collection("events")
          .where("date", isGreaterThan: Timestamp.now())
          .orderBy("date")
          .limit(5)
          .get();
      await Future.forEach(snapShot.docs, (final snapShot) async {
        List<String> attendeeIDs = [];
        final event = snapShot.data();
        final BabylonUser? creator =
            await UserService.getBabylonUser(userUID: event["creator"]);
        if (event.containsKey("attendees")) {
          attendeeIDs = List<String>.from(event["attendees"]);
        }

        result.add(Event(
            snapshot: snapShot,
            eventUID: snapShot.reference.id,
            title: event["title"] ?? "" ?? "",
            creatorUID: event["creator"],
            creator: creator!,
            place: event["place"] ?? "",
            date: (event["date"] as Timestamp).toDate(),
            fullDescription: event["fullDescription"] ?? "",
            shortDescription: event["shortDescription"] ?? "",
            pictureURL: event["picture"] ?? "",
            attendeesUIDs: attendeeIDs));
      });
    } catch (error) {
      print(error);
    }
    return result;
  }

  static Future<List<Event>> getMoreEvents(final Event lastVisibleEvent) async {
    final List<Event> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db
          .collection("events")
          .where("date", isGreaterThan: Timestamp.now())
          .orderBy("date")
          .limit(5)
          .startAfterDocument(lastVisibleEvent.snapshot!)
          .get();
      await Future.forEach(snapShot.docs, (final snapShot) async {
        List<String> attendeeIDs = [];
        final event = snapShot.data();
        final BabylonUser? creator =
            await UserService.getBabylonUser(userUID: event["creator"]);
        if (event.containsKey("attendees")) {
          attendeeIDs = List<String>.from(event["attendees"]);
        }

        result.add(Event(
            snapshot: snapShot,
            eventUID: snapShot.reference.id,
            title: event["title"] ?? "" ?? "",
            creatorUID: event["creator"],
            creator: creator!,
            place: event["place"] ?? "",
            date: (event["date"] as Timestamp).toDate(),
            fullDescription: event["fullDescription"] ?? "",
            shortDescription: event["shortDescription"] ?? "",
            pictureURL: event["picture"] ?? "",
            attendeesUIDs: attendeeIDs));
      });
    } catch (error) {
      print(error);
    }
    return result;
  }

  static Future<Event?> getEvent({required final String eventUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      final eventSnapshot = await db.collection("events").doc(eventUID).get();
      final eventData = eventSnapshot.data();
      List<String> attendeeIDs = [];
      if (eventData != null &&
          eventData["date"].toDate().isAfter(DateTime.now())) {
        final BabylonUser? creator =
            await UserService.getBabylonUser(userUID: eventData["creator"]);

        if (eventData.containsKey("attendees")) {
          attendeeIDs = List<String>.from(eventData["attendees"]);
        }

        return Event(
            eventUID: eventSnapshot.id,
            creator: creator,
            creatorUID: eventData["creator"],
            title: eventData["title"] ?? "",
            place: eventData["place"],
            date: (eventData["date"] as Timestamp).toDate(),
            fullDescription: eventData["fullDescription"],
            shortDescription: eventData["shortDescription"],
            pictureURL: eventData["picture"] ?? "",
            attendeesUIDs: attendeeIDs);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Event>> getListedEventsOfUser(
      {required final String uuid}) async {
    try {
      final List<Event> result = List<Event>.empty(growable: true);
      final BabylonUser? babylonUser =
          await UserService.getBabylonUser(userUID: uuid);

      if (babylonUser != null) {
        await Future.forEach(babylonUser.listedEventsUIDs,
            (final anEventUID) async {
          final Event? anEvent = await getEvent(eventUID: anEventUID);
          if (anEvent != null) result.add(anEvent);
        });
      }
      return result;
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  static Future<bool> addUserToEvent({required final Event event}) async {
    try {
      final BabylonUser currUser = ConnectedBabylonUser();
      currUser.listedEventsUIDs.add(event.eventUID);
      final db = FirebaseFirestore.instance;
      await db.collection("users").doc(currUser.userUID).update({
        "listedEvents": FieldValue.arrayUnion([event.eventUID])
      });
      await db.collection("events").doc(event.eventUID).update({
        "attendees": FieldValue.arrayUnion([currUser.userUID])
      });
      ConnectedBabylonUser.setConnectedBabylonUser(babylonUser: currUser);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> createEvent(
      {required final String eventName,
      final File? image,
      required final Timestamp eventTimeStamp,
      final String? shortDescription,
      final String? description,
      required final String place}) async {
    try {
      final User currUser = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;
      final Reference referenceRoot = FirebaseStorage.instance.ref();
      final Reference referenceDirImages = referenceRoot.child("images");

      final newEvent = <String, dynamic>{
        "title": eventName,
        "creator": currUser.uid,
        "shortDescription": shortDescription,
        "fullDescription": description,
        "date": eventTimeStamp,
        "place": place,
      };

      if (image != null) {
        final String imgName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        final Reference referenceImageToUpload =
            referenceDirImages.child(imgName);
        await referenceImageToUpload.putFile(image);
        newEvent["picture"] = await referenceImageToUpload.getDownloadURL();
      }

      db.collection("events").doc().set(newEvent);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<void> updateEvent(
      {required final String eventUID,
      required final String eventName,
      final File? image,
      required final Timestamp eventTimeStamp,
      final String? shortDescription,
      final String? description,
      required final String place}) async {
    try {
      final User currUser = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;
      final Reference referenceRoot = FirebaseStorage.instance.ref();
      final Reference referenceDirImages = referenceRoot.child("images");

      final newEventData = <String, dynamic>{
        "title": eventName,
        "creator": currUser.uid,
        "shortDescription": shortDescription,
        "fullDescription": description,
        "date": eventTimeStamp,
        "place": place,
      };

      if (image != null) {
        final String imgName =
            "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
        final Reference referenceImageToUpload =
            referenceDirImages.child(imgName);
        await referenceImageToUpload.putFile(image);
        newEventData["picture"] = await referenceImageToUpload.getDownloadURL();
      }

      db.collection("events").doc(eventUID).update(newEventData);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getAttendees(
      {required final Event event}) async {
    try {
      return await UserService.getBabylonUsersFromUIDs(
          userUIDList: event.attendeesUIDs);
    } catch (e) {
      rethrow;
    }
  }
}
