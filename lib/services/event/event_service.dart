import "dart:io";

import "package:babylon_app/models/babylon_user.dart";
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
          .get();
      await Future.forEach(snapShot.docs, (final snapShot) async {
        List<String> attendeeIDs = [];
        final event = snapShot.data();
        final BabylonUser? creator =
            await UserService.getBabylonUser(userUID: event["creator"]);
        if (event.containsKey("attendees")) {
          attendeeIDs = List<String>.from(event["attendees"]);
        }
        final imageUrl = event.containsKey("picture")
            ? await FirebaseStorage.instance
                .ref()
                .child(event["picture"])
                .getDownloadURL()
            : "";
        result.add(Event(
            eventUID: snapShot.reference.id,
            title: event["title"] ?? "" ?? "",
            creatorUID: event["creator"],
            creator: creator!,
            place: event["place"] ?? "",
            date: (event["date"] as Timestamp).toDate(),
            fullDescription: event["fullDescription"] ?? "",
            shortDescription: event["shortDescription"] ?? "",
            pictureURL: imageUrl,
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
      if (eventData != null) {
        final BabylonUser? creator =
            await UserService.getBabylonUser(userUID: eventData["creator"]);
        String imageUrl = "";
        if (eventData.keys.contains("picture")) {
          imageUrl = await FirebaseStorage.instance
              .ref()
              .child(eventData["picture"])
              .getDownloadURL();
        }

        if (eventData.containsKey("attendees")) {
          attendeeIDs = List<String>.from(eventData["attendees"]);
        }

        return Event(
            eventUID: eventSnapshot.id,
            creator: creator!,
            creatorUID: eventData["creator"],
            title: eventData["title"] ?? "",
            place: eventData["place"] ?? "",
            date: (eventData["date"] as Timestamp).toDate(),
            fullDescription: eventData["fullDescription"] ?? "",
            shortDescription: eventData["shortDescription"] ?? "",
            pictureURL: imageUrl,
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

      if (babylonUser != null && babylonUser.listedEventsUIDs != null) {
        await Future.forEach(babylonUser.listedEventsUIDs!,
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
      final User currUser = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;
      await db.collection("users").doc(currUser.uid).update({
        "listedEvents": FieldValue.arrayUnion([event.eventUID])
      });
      await db.collection("events").doc(event.eventUID).update({
        "attendees": FieldValue.arrayUnion([currUser.uid])
      });
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
        newEvent["picture"] = "/images/${imgName}";
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
        newEventData["picture"] = "/images/${imgName}";
      }

      db.collection("events").doc(eventUID).update(newEventData);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
