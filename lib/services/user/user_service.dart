import "dart:async";
import "dart:convert";
import "dart:typed_data";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "dart:io";

class UserService {
  static Future<void> fillUser(
      {required final User user,
      required final Map<String, String> userInfo}) async {
    final db = FirebaseFirestore.instance;

    final docUser = db.collection("users").doc(user.uid);

    try {
      await docUser.set(userInfo);
    } catch (e) {
      print("Error writing document: $e");
    }
  }

  static Future<void> addPhoto(
      {required final User user, required final File file}) async {
    final Reference referenceRoot = FirebaseStorage.instance.ref();
    final Reference referenceDirImages = referenceRoot.child("images");
    final String imgName = "${user.uid}.jpg";
    final Reference referenceImageToUpload = referenceDirImages.child(imgName);
    String imgUrl = "";
    try {
      await referenceImageToUpload.putFile(file);
      imgUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      print(error);
    }
    if (imgUrl.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"ImageUrl": imgUrl})
          .then((final value) => print("User Updated and photo added"))
          .catchError(
              (final error) => print("Failed to add the photo: $error"));

      try {
        await user.updatePhotoURL(imgUrl);
      } catch (error) {
        print("Failed to add the photo to user in auth: $error");
      }
    }
  }

  static Future<void> updateUserInfo(
      {required final String uuid,
      final Map<String, String>? newData,
      final Map<String, bool>? activities,
      final Map<String, bool>? music,
      final Map<String, bool>? hobbies}) async {
    final userActivities = [], userMusic = [], userHobbies = [];

    if (activities != null) {
      for (final activity in activities.entries) {
        if (activity.value) userActivities.add(activity.key);
      }
    }

    if (music != null) {
      for (final music in music.entries) {
        if (music.value) userMusic.add(music.key);
      }
    }

    if (hobbies != null) {
      for (final hobby in hobbies.entries) {
        if (hobby.value) userHobbies.add(hobby.key);
      }
    }

    if (userActivities.isNotEmpty ||
        userMusic.isNotEmpty ||
        userHobbies.isNotEmpty ||
        newData!.isNotEmpty) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(uuid)
          .update({
            "activities": userActivities,
            "music": userMusic,
            "hobbies": userHobbies,
            "Country of Origin": newData!.containsKey("originCountry")
                ? newData["originCountry"]
                : "",
            "Date of Birth":
                newData.containsKey("birthDate") ? newData["birthDate"] : "",
            "About": newData.containsKey("about") ? newData["about"] : "",
            "Name": newData.containsKey("name") ? newData["name"] : "",
          })
          .then((final value) => print("User Updated and additionalInfo added"))
          .catchError((final error) =>
              print("Failed to add the additionalInfo: $error"));
    }
  }

  static Future<Image> convertFileToImage(final File picture) async {
    final List<int> imageBase64 = picture.readAsBytesSync();
    final String imageAsString = base64Encode(imageBase64);
    final Uint8List uint8list = base64.decode(imageAsString);
    final Image image = Image.memory(uint8list);
    return image;
  }

  static Future<BabylonUser?> getBabylonUser(final String userUID) async {
    BabylonUser? result;
    final Map<String, String> userInfo = {};

    try {
      final List<String> eventsLists = List.empty(growable: true);
      final List<String> connectionsList = List.empty(growable: true);
      final db = FirebaseFirestore.instance;
      final docUser = await db.collection("users").doc(userUID).get();
      final userData = docUser.data();
      userInfo["name"] = userData!.containsKey("Name") ? userData["Name"] : "";
      userInfo["email"] = userData.containsKey("Email Address")
          ? userData["Email Address"]
          : "";
      userInfo["imgURL"] =
          userData.containsKey("ImageUrl") ? userData["ImageUrl"] : "";
      userInfo["UUID"] = docUser.id;
      userInfo["about"] =
          userData.containsKey("About") ? userData["About"] : "";
      userInfo["country"] = userData.containsKey("Country of Origin")
          ? userData["Country of Origin"]
          : "";
      userInfo["birthDate"] = userData.containsKey("Date of Birth")
          ? userData["Date of Birth"]
          : "";

      final docsListedEvents = await db
          .collection("users")
          .doc(userUID)
          .collection("listedEvents")
          .get();
      final docsListedConnections = await db
          .collection("users")
          .doc(userUID)
          .collection("connections")
          .get();

      await Future.forEach(docsListedEvents.docs, (final snapShot) async {
        eventsLists.add(snapShot.reference.id);
      });
      await Future.forEach(docsListedConnections.docs,
          (final snapShot) async => connectionsList.add(snapShot.reference.id));

      result = BabylonUser.withData(
          userInfo["UUID"]!,
          userInfo["name"]!,
          userInfo["email"]!,
          userInfo["about"]!,
          userInfo["country"]!,
          userInfo["birthDate"]!,
          userInfo["imgURL"]!,
          eventsLists,
          connectionsList);
      print(userData);
    } catch (e) {
      print(e);
    }
    return result;
  }

  static Future<List<BabylonUser?>> getBabylonUsersFromUIDs(
      {required final List<String> userUIDList}) async {
    try {
      final List<BabylonUser?> babylonUserList = [];
      await Future.forEach(userUIDList, (final userUID) async {
        babylonUserList.add(await getBabylonUser(userUID));
      });
      return babylonUserList;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser?>> getConnections() async {
    final List<BabylonUser?> connections = [];
    await Future.forEach(ConnectedBabylonUser().listedConnections,
        (final connectionId) async {
      final BabylonUser? babylonUser = await getBabylonUser(connectionId);
      connections.add(babylonUser);
    });
    connections.sort((final connection1, final connection2) =>
        connection1!.fullName.compareTo(connection2!.fullName));
    return connections;
  }

  static Future<List<BabylonUser?>> getRequests() async {
    final List<BabylonUser?> requests = [];
    await Future.forEach(ConnectedBabylonUser().listedRequests,
        (final requestId) async {
      final BabylonUser? babylonUser = await getBabylonUser(requestId);
      requests.add(babylonUser);
    });
    return requests;
  }

  static void createRequest(final String requestUID) async {
    final db = FirebaseFirestore.instance;
    final userUID = ConnectedBabylonUser().userUID;
    db
        .collection("users")
        .doc(requestUID)
        .collection("requests")
        .doc(userUID)
        .set({});
  }

  static void removeConnection(final String connectionUID) async {
    final db = FirebaseFirestore.instance;
    final userUID = ConnectedBabylonUser().userUID;
    db
        .collection("users")
        .doc(userUID)
        .collection("connections")
        .doc(connectionUID)
        .delete();
    db
        .collection("users")
        .doc(connectionUID)
        .collection("connections")
        .doc(userUID)
        .delete();
    ConnectedBabylonUser().listedConnections.remove(connectionUID);
  }

  static void addRequestConnection(final String requestUID) async {
    final db = FirebaseFirestore.instance;
    final userUID = ConnectedBabylonUser().userUID;
    db
        .collection("users")
        .doc(userUID)
        .collection("connections")
        .doc(requestUID)
        .set({});
    db
        .collection("users")
        .doc(requestUID)
        .collection("connections")
        .doc(userUID)
        .set({});
    db
        .collection("users")
        .doc(userUID)
        .collection("requests")
        .doc(requestUID)
        .delete();
    ConnectedBabylonUser().listedConnections.add(requestUID);
    ConnectedBabylonUser().listedRequests.remove(requestUID);
  }

  static void removeRequestConnection(final String requestUID) async {
    final db = FirebaseFirestore.instance;
    await db
        .collection("users")
        .doc(ConnectedBabylonUser().userUID)
        .collection("requests")
        .doc(requestUID)
        .delete();
    ConnectedBabylonUser().listedRequests.remove(requestUID);
  }

  static void setUpConnectedBabylonUser(final String userUID) async {
    final BabylonUser? babylonUser = await getBabylonUser(userUID);
    final List<String> requestsList = List.empty(growable: true);

    final db = FirebaseFirestore.instance;
    final docsListedRequests =
        await db.collection("users").doc(userUID).collection("requests").get();
    await Future.forEach(docsListedRequests.docs,
        (final snapshot) async => requestsList.add(snapshot.reference.id));

    await ConnectedBabylonUser.setConnectedBabylonUser(babylonUser);
    await ConnectedBabylonUser.setRequests(requestsList);
  }

  static Future<List<BabylonUser>> getAllBabylonUsers() async {
    final List<BabylonUser> users = [];
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection("users").limit(20).get();
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final List<String> eventsLists = [];
        final List<String> connectionsLists = [];
        final user = BabylonUser.withData(
            doc.id,
            data["Name"] ?? "",
            data["Email Address"] ?? "",
            data["About"] ?? "",
            data["Country of Origin"] ?? "",
            data["Date of Birth"] ?? "",
            data["ImageUrl"] ?? "",
            eventsLists,
            connectionsLists);
        users.add(user);
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
    return users;
  }

  static Future<List<String>> _getSubCollectionData(
      final DocumentReference parentRef, final String subCollection) async {
    final List<String> subCollectionData = [];
    try {
      final snapshot = await parentRef.collection(subCollection).get();
      for (final doc in snapshot.docs) {
        subCollectionData.add(doc.id);
      }
    } catch (e) {
      print("Error fetching sub collection data for $subCollection: $e");
    }
    return subCollectionData;
  }

  static Future<List<BabylonUser>> searchBabylonUsers(
      final String query) async {
    final List<BabylonUser> searchResults = [];
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db
          .collection("users")
          .where("Name", isGreaterThanOrEqualTo: query)
          .where("Name", isLessThanOrEqualTo: "$query\uf8ff")
          .get();

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final user = BabylonUser.withData(
            doc.id,
            data["Name"] ?? "",
            data["Email Address"] ?? "",
            data["About"] ?? "",
            data["Country of Origin"] ?? "",
            data["Date of Birth"] ?? "",
            data["ImageUrl"] ?? "", [], []);
        searchResults.add(user);
      }
    } catch (e) {
      print("Error searching users: $e");
    }
    return searchResults;
  }
}
