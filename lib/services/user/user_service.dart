import "dart:async";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";
import "dart:io";

class UserService {
  static Future<void> fillUser(
      {required final User user,
      required final Map<String, String> userInfo}) async {
    try {
      final db = FirebaseFirestore.instance;
      final docUser = db.collection("users").doc(user.uid);
      await docUser.set(userInfo);
    } catch (e) {
      print("Error writing document: $e");
      rethrow;
    }
  }

  static Future<void> addPhoto(
      {required final User user, required final File file}) async {
    String imgUrl = "";
    try {
      final Reference referenceRoot = FirebaseStorage.instance.ref();
      final Reference referenceDirImages = referenceRoot.child("images");
      final String imgName = "${user.uid}.jpg";
      final Reference referenceImageToUpload =
          referenceDirImages.child(imgName);
      await referenceImageToUpload.putFile(file);
      imgUrl = await referenceImageToUpload.getDownloadURL();

      if (imgUrl.isNotEmpty) {
        FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"ImageUrl": imgUrl})
            .then((final value) => print("User Updated and photo added"))
            .catchError(
                (final error) => print("Failed to add the photo: $error"));

        await user.updatePhotoURL(imgUrl);
      }
    } catch (error) {
      print("Failed to add the photo to user in auth: $error");
    }
  }

  static Future<void> updateUserInfo(
      {required final String uuid,
      final Map<String, String>? newData,
      final Map<String, bool>? activities,
      final Map<String, bool>? music,
      final Map<String, bool>? hobbies}) async {
    try {
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
        await FirebaseFirestore.instance.collection("users").doc(uuid).update({
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
        });
      }
    } catch (e) {
      print("Failed to add the additionalInfo: $e");
      rethrow;
    }
  }

  static Future<BabylonUser?> getBabylonUser(
      {required final String userUID}) async {
    try {
      List<String> eventsListsUIDs = [];
      List<String> connectionsListUIDs = [];
      List<String> connectionRequestsListUIDs = [];
      List<String> sentPendingConnectionRequestListUIDs = [];
      List<String> groupChatInvitationsListUIDs = [];
      List<String> groupChatJoinRequestsListUIDs = [];

      final db = FirebaseFirestore.instance;
      final docUser = await db.collection("users").doc(userUID).get();
      final userData = docUser.data();

      if (userData != null) {
        if (userData.containsKey("connections")) {
          connectionsListUIDs = List<String>.from(userData["connections"]);
        }

        if (userData.containsKey("listedEvents")) {
          eventsListsUIDs = List<String>.from(userData["listedEvents"]);
        }

        if (userData.containsKey("connectionRequests")) {
          connectionRequestsListUIDs =
              List<String>.from(userData["connectionRequests"]);
        }

        if (userData.containsKey("sentConnectionRequests")) {
          sentPendingConnectionRequestListUIDs =
              List<String>.from(userData["sentConnectionRequests"]);
        }

        if (userData.containsKey("groupChatInvitations")) {
          groupChatInvitationsListUIDs =
              List<String>.from(userData["groupChatInvitations"]);
        }

        if (userData.containsKey("groupChatJoiningRequests")) {
          groupChatJoinRequestsListUIDs =
              List<String>.from(userData["groupChatJoiningRequests"]);
        }

        return BabylonUser.withData(
          userUID: docUser.id,
          fullName: userData["Name"] ?? "",
          email: userData["Email Address"] ?? "",
          imagePath: userData["ImageUrl"],
          about: userData["About"],
          originCountry: userData["Country of Origin"],
          dateOfBirth: userData["Date of Birth"],
          listedEventsUIDs: eventsListsUIDs,
          listedConnectionsUIDs: connectionsListUIDs,
          connectionRequestsUIDs: connectionRequestsListUIDs,
          sentPendingConnectionRequestsUIDs:
              sentPendingConnectionRequestListUIDs,
          groupChatInvitationsUIDs: groupChatInvitationsListUIDs,
          groupChatJoinRequestsUIDs: groupChatJoinRequestsListUIDs,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getBabylonUsersFromUIDs(
      {required final List<String>? userUIDList}) async {
    try {
      final List<BabylonUser> babylonUserList = [];
      await Future.forEach(userUIDList!, (final userUID) async {
        final babylonUser = await getBabylonUser(userUID: userUID);
        if (babylonUser != null) {
          babylonUserList.add(babylonUser);
        }
      });
      return babylonUserList;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getAllBabylonUsers() async {
    final List<BabylonUser> users = [];
    try {
      final db = FirebaseFirestore.instance;
      final querySnapshot = await db.collection("users").limit(20).get();
      for (final doc in querySnapshot.docs) {
        final userData = doc.data();

        List<String> eventsListsUIDs = [];
        List<String> connectionsListUIDs = [];
        List<String> connectionRequestsListUIDs = [];

        if (userData.containsKey("connections")) {
          connectionsListUIDs = List<String>.from(userData["connections"]);
        }

        if (userData.containsKey("listedEvents")) {
          eventsListsUIDs = List<String>.from(userData["listedEvents"]);
        }

        if (userData.containsKey("connectionRequests")) {
          connectionRequestsListUIDs =
              List<String>.from(userData["connectionRequests"]);
        }

        users.add(BabylonUser.withData(
          userUID: doc.id,
          fullName: userData["Name"] ?? "",
          email: userData["Email Address"] ?? "",
          imagePath: userData["ImageUrl"] ?? "",
          about: userData["About"],
          originCountry: userData["Country of Origin"],
          dateOfBirth: userData["Date of Birth"],
          listedEventsUIDs: eventsListsUIDs,
          listedConnectionsUIDs: connectionsListUIDs,
          connectionRequestsUIDs: connectionRequestsListUIDs,
        ));
      }
    } catch (e) {
      print("Error fetching users: $e");
    }
    return users;
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
        final userData = doc.data();
        List<String> eventsListsUIDs = [];
        List<String> connectionsListUIDs = [];
        List<String> connectionRequestsListUIDs = [];

        if (userData.containsKey("connections")) {
          connectionsListUIDs = List<String>.from(userData["connections"]);
        }

        if (userData.containsKey("listedEvents")) {
          eventsListsUIDs = List<String>.from(userData["listedEvents"]);
        }

        if (userData.containsKey("connectionRequests")) {
          connectionRequestsListUIDs =
              List<String>.from(userData["connectionRequests"]);
        }

        searchResults.add(BabylonUser.withData(
          userUID: doc.id,
          fullName: userData["Name"] ?? "",
          email: userData["Email Address"] ?? "",
          imagePath: userData["ImageUrl"] ?? "",
          about: userData["About"],
          originCountry: userData["Country of Origin"],
          dateOfBirth: userData["Date of Birth"],
          listedEventsUIDs: eventsListsUIDs,
          listedConnectionsUIDs: connectionsListUIDs,
          connectionRequestsUIDs: connectionRequestsListUIDs,
        ));
      }
    } catch (e) {
      print("Error searching users: $e");
    }
    return searchResults;
  }

  static Future<List<BabylonUser>> getConnections() async {
    try {
      List<BabylonUser> connections = [];
      final BabylonUser currUser = ConnectedBabylonUser();
      if (currUser.listedConnectionsUIDs != null) {
        connections = await getBabylonUsersFromUIDs(
            userUIDList: currUser.listedConnectionsUIDs);
      }
      connections.sort((final connection1, final connection2) =>
          connection1.fullName.compareTo(connection2.fullName));
      return connections;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getConnectionsRequests() async {
    try {
      List<BabylonUser> requests = [];
      requests = await getBabylonUsersFromUIDs(
          userUIDList: ConnectedBabylonUser().connectionRequestsUIDs);
      return requests;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getSentPendingConnectionsRequests() async {
    try {
      return await getBabylonUsersFromUIDs(
          userUIDList:
              ConnectedBabylonUser().sentPendingConnectionRequestsUIDs);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeConnectionToUser(
      {required final String connectionUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      final BabylonUser currUser = ConnectedBabylonUser();
      if (currUser.listedConnectionsUIDs != null) {
        db.collection("users").doc(currUser.userUID).update({
          "connections": FieldValue.arrayRemove([connectionUID])
        });
        db.collection("users").doc(connectionUID).update({
          "connections": FieldValue.arrayRemove([currUser.userUID])
        });
        ConnectedBabylonUser().listedConnectionsUIDs!.remove(connectionUID);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addConnectionToUser(
      {required final String requestUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      final BabylonUser currUser = ConnectedBabylonUser();
      if (currUser.listedConnections != null && currUser.listedEvents != null) {
        final userUID = currUser.userUID;
        db.collection("users").doc(userUID).update({
          "connections": FieldValue.arrayUnion([requestUID])
        });
        db.collection("users").doc(requestUID).update({
          "connections": FieldValue.arrayUnion([userUID])
        });
        db.collection("users").doc(userUID).update({
          "connectionRequests": FieldValue.arrayRemove([requestUID])
        });
        ConnectedBabylonUser().listedConnectionsUIDs!.add(requestUID);
        ConnectedBabylonUser().connectionRequestsUIDs!.remove(requestUID);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeConnectionRequest(
      {required final String requestUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection("users").doc(ConnectedBabylonUser().userUID).update({
        "connectionRequests": FieldValue.arrayRemove([requestUID])
      });
      ConnectedBabylonUser().connectionRequestsUIDs!.remove(requestUID);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendConnectionRequest(
      {required final String requestUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      await db.collection("users").doc(requestUID).update({
        "connectionRequests":
            FieldValue.arrayUnion([ConnectedBabylonUser().userUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> setUpConnectedBabylonUser(
      {required final String userUID}) async {
    try {
      final BabylonUser? babylonUser = await getBabylonUser(userUID: userUID);
      if (babylonUser != null) {
        await ConnectedBabylonUser.setConnectedBabylonUser(
            babylonUser: babylonUser);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Chat>> getGroupChatInvitations(
      {required final String userUID}) async {
    try {
      final BabylonUser? babylonUser = await getBabylonUser(userUID: userUID);
      if (babylonUser != null) {
        return await ChatService.getChatsFromUIDs(
            chatUIDList: babylonUser.groupChatInvitationsUIDs);
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Chat>> getGroupChatJoinRequests(
      {required final String userUID}) async {
    try {
      final BabylonUser? babylonUser = await getBabylonUser(userUID: userUID);
      if (babylonUser != null) {
        return await ChatService.getChatsFromUIDs(
            chatUIDList: babylonUser.groupChatJoinRequestsUIDs);
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
