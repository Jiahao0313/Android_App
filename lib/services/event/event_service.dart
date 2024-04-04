import "dart:io";

import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_storage/firebase_storage.dart";

class EventService {
  static Future<List<Event>> getEvents() async {
    final List<Event> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db.collection("events").get();
      await Future.forEach(snapShot.docs, (final snapShot) async {
        List<String> attendeeIDs = [];
        final event = snapShot.data();

        if (event.containsKey("attendees")) {
          attendeeIDs = List<String>.from(event["attendees"]);
        }
        final imageUrl = event.containsKey("picture")
            ? await FirebaseStorage.instance
                .ref()
                .child(event["picture"])
                .getDownloadURL()
            : "";
        final Event? anEvent = await Event.create(
            newEventDocumentID: snapShot.reference.id,
            newTitle: event["title"],
            babylonUserUID: event["creator"],
            newPlace: event["place"],
            newDate: (event["date"] as Timestamp).toDate(),
            newFullDescription: event["fullDescription"],
            newShortDescription: event["shortDescription"],
            newPictureURL: imageUrl,
            attendeeIDs: attendeeIDs);
        if (anEvent != null) result.add(anEvent);
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

        final Event? anEvent = await Event.create(
            newEventDocumentID: eventSnapshot.id,
            newTitle: eventData["title"] ?? "",
            babylonUserUID: eventData["creator"] ?? "",
            newPlace: eventData["place"] ?? "",
            newDate: (eventData["date"] as Timestamp).toDate(),
            newFullDescription: eventData["fullDescription"] ?? "",
            newShortDescription: eventData["shortDescription"] ?? "",
            newPictureURL: imageUrl,
            attendeeIDs: attendeeIDs);
        if (anEvent != null) {
          return anEvent;
        }
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

      if (babylonUser != null && babylonUser.listedEvents != null) {
        await Future.forEach(babylonUser.listedEvents!,
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
        "listedEvents": FieldValue.arrayUnion([event.eventDocumentID])
      });
      await db.collection("events").doc(event.eventDocumentID).update({
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
