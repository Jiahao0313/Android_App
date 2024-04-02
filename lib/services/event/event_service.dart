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
        final List<String> attendeesID = List.empty(growable: true);
        final attendeesSnapshot = await db
            .collection("events")
            .doc(snapShot.id)
            .collection("attendees")
            .get();
        attendeesSnapshot.docs.forEach((final anAttendee) {
          attendeesID.add(anAttendee.id);
        });

        final event = snapShot.data();
        final imageUrl = event.containsKey("picture")
            ? await FirebaseStorage.instance
                .ref()
                .child(event["picture"])
                .getDownloadURL()
            : "";
        result.add(await Event.create(
            snapShot.reference.id,
            event["title"],
            event["creator"],
            event["place"],
            (event["date"] as Timestamp).toDate(),
            event["fullDescription"],
            event["shortDescription"],
            imageUrl,
            attendeesID));
      });
    } catch (error) {
      print(error);
    }
    return result;
  }

  static Future<List<Event>> getListedEventsOfUser(final String uuid) async {
    final BabylonUser? babylonUser = await UserService.getBabylonUser(uuid);
    final List<Event> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db.collection("events").get();
      await Future.forEach(snapShot.docs, (final snapShot) async {
        final event = snapShot.data();
        if (babylonUser!.listedEvents.contains(snapShot.reference.id)) {
          final List<String> attendeesID = List.empty(growable: true);
          final attendeesSnapshot = await db
              .collection("events")
              .doc(snapShot.id)
              .collection("attendees")
              .get();
          attendeesSnapshot.docs.forEach((final anAttendee) {
            attendeesID.add(anAttendee.id);
          });

          String imageUrl = "";
          if(event.keys.contains("picture")) {
            imageUrl = await FirebaseStorage.instance
              .ref()
              .child(event["picture"])
              .getDownloadURL(); 
          }
          result.add(await Event.create(
              snapShot.reference.id,
              event["title"],
              event["creator"],
              event["place"],
              (event["date"] as Timestamp).toDate(),
              event["fullDescription"],
              event["shortDescription"],
              imageUrl,
              attendeesID));
        }
      });
    } catch (error) {
      print(error);
    }
    return result;
  }

  static Future<bool> addUserToEvent(final Event event) async {
    try {
      final User currUser = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;
      await db
          .collection("users")
          .doc(currUser.uid)
          .collection("listedEvents")
          .doc(event.eventDocumentID)
          .set({});
      await db
          .collection("events")
          .doc(event.eventDocumentID)
          .collection("attendees")
          .doc(currUser.uid)
          .set({});
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
