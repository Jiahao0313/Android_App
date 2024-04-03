import "dart:async";

import "dart:io";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/message.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

class ChatService {
  static StreamController<List<Message>> getChatStream(
      {required final chatUID}) {
    try {
      final StreamController<List<Message>> streamController =
          StreamController();
      FirebaseFirestore.instance
          .collection("chats")
          .doc(chatUID)
          .collection("messages")
          .orderBy("time", descending: true)
          .snapshots()
          .listen((final querySnapshot) async {
        final List<Message> messages = [];
        for (final messageDoc in querySnapshot.docs) {
          messages.add(Message(
            messageDocumentID: messageDoc.id,
            message: messageDoc["message"],
            time: messageDoc["time"],
            senderUID: messageDoc["sender"],
          ));
        }
        streamController.add(messages);
      });
      return streamController;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendMessage(
      {required final String chatUID, required final Message message}) async {
    try {
      await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatUID)
          .collection("messages")
          .doc()
          .set({
        "message": message.message,
        "time": message.time,
        "sender": message.senderUID
      });

      // update chat's last message
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "lastMessage": message.message,
        "lastMessageTime": message.time,
        "lastSender": message.senderUID
      });
    } catch (e) {
      rethrow;
    }
  }

  // if otherUser is set, you will create a single chat. If not, you will create a groupchat
  static Future<void> createChat(
      {final String? adminUID,
      final String? chatDescription,
      final String? chatName,
      final File? image,
      final List<String> usersUID = const [],
      final BabylonUser? otherUser}) async {
    try {
      final db = FirebaseFirestore.instance;
      final newChatData = <String, dynamic>{};
      final BabylonUser curr = ConnectedBabylonUser();
      if (otherUser != null) {
        if (otherUser.userUID != ConnectedBabylonUser().userUID) {
          newChatData["users"] =
              FieldValue.arrayUnion([curr.userUID, otherUser.userUID]);
          final String chatDocID =
              curr.userUID.compareTo(otherUser.userUID) == -1
                  ? "${curr.userUID}_${otherUser.userUID}"
                  : "${otherUser.userUID}_${curr.userUID}";
          await db.collection("chats").doc(chatDocID).set(newChatData);
        }
      } else {
        newChatData["chatName"] = chatName;
        newChatData["admin"] = adminUID;
        if (chatDescription != null) {
          newChatData["chatDescription"] = chatDescription;
        }

        if (image != null) {
          final Reference referenceRoot = FirebaseStorage.instance.ref();
          final Reference referenceDirImages = referenceRoot.child("images");
          final String imgName =
              "${DateTime.now().millisecondsSinceEpoch.toString()}.jpg";
          final Reference referenceImageToUpload =
              referenceDirImages.child(imgName);
          await referenceImageToUpload.putFile(image);
          newChatData["iconPath"] = "/images/${imgName}";
        }
        if (usersUID.isNotEmpty) {
          newChatData["users"] = FieldValue.arrayUnion(usersUID);
        }
        await db.collection("chats").doc().set(newChatData);
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Chat>> getUserChats(
      {required final String userUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      final List<Chat> res = List<Chat>.empty(growable: true);
      final userChats = await db
          .collection("chats")
          .where("users", arrayContains: userUID)
          .get();
      await Future.forEach(userChats.docs, (final snapShot) async {
        final chat = await ChatService.getChatFromUID(chatUID: snapShot.id);
        if (chat != null) {
          res.add(chat);
        }
      });

      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BabylonUser>> getChatUsers(
      {required final String chatUID}) async {
    try {
      final List<BabylonUser> res = List<BabylonUser>.empty(growable: true);
      final db = FirebaseFirestore.instance;
      final chatDoc = await db.collection("chats").doc(chatUID).get();
      final chatData = chatDoc.data();
      final List<String> userIDList = List<String>.from(chatData!["users"]);
      await Future.forEach(userIDList, (final userID) async {
        res.add((await UserService.getBabylonUser(userUID: userID))!);
      });
      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addUserToGroupChatBanList(
      {required final String userUID, required final String chatUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "bannedUsers": FieldValue.arrayUnion([userUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> removeUserOfGroupChatBanList(
      {required final String userUID, required final String chatUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "bannedUsers": FieldValue.arrayRemove([userUID])
      });
    } catch (e) {
      rethrow;
    }
  }

// groupchat invitations
  static Future<void> sendGroupChatInvitation(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "sentInvitations": FieldValue.arrayUnion([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatInvitations": FieldValue.arrayUnion([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cancelGroupChatInvitation(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "sentInvitations": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatInvitations": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> acceptGroupChatInvitation(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "users": FieldValue.arrayUnion([userUID])
      });
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "sentInvitations": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatInvitations": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> declineGroupChatInvitation(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "sentInvitations": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatInvitations": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

// groupchat join requests
  static Future<void> sendGroupChatJoinRequest(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "joiningRequests": FieldValue.arrayUnion([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatJoiningRequests": FieldValue.arrayUnion([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> cancelGroupChatJoinRequest(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "joiningRequests": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatJoiningRequests": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> acceptGroupChatJoinRequest(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "users": FieldValue.arrayUnion([userUID])
      });
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "groupChatJoiningRequests": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "joiningRequests": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> declineGroupChatJoinRequest(
      {required final String chatUID, required final String userUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "joiningRequests": FieldValue.arrayRemove([userUID])
      });
      await FirebaseFirestore.instance.collection("users").doc(userUID).update({
        "groupChatJoiningRequests": FieldValue.arrayRemove([chatUID])
      });
    } catch (e) {
      rethrow;
    }
  }

  static Future<Chat?> getChatFromUID({required final String chatUID}) async {
    try {
      final db = FirebaseFirestore.instance;
      final chatSnapshot = await db.collection("chats").doc(chatUID).get();
      final chatData = chatSnapshot.data();

      if (chatData != null) {
        //if is groupchat (has admin)
        if (chatData.containsKey("admin") && chatData["admin"] != "") {
          final imageUrl = await FirebaseStorage.instance
              .ref()
              .child(chatData["iconPath"])
              .getDownloadURL();

          return Chat(
              chatUID: chatSnapshot.id,
              adminUID: chatData["admin"],
              chatName: chatData["chatName"],
              iconPath: imageUrl,
              bannedUsersUID: chatData.containsKey("bannedUsers")
                  ? List<String>.from(chatData["bannedUsers"])
                  : [],
              joiningRequests: chatData.containsKey("joiningRequests")
                  ? List<String>.from(chatData["joiningRequests"])
                  : [],
              sentInvitations: chatData.containsKey("sentInvitations")
                  ? List<String>.from(chatData["sentInvitations"])
                  : [],
              lastMessage: chatData.containsKey("lastMessage") &&
                      chatData.containsKey("lastMessageTime") &&
                      chatData.containsKey("lastSender") &&
                      chatData["lastMessage"] != "" &&
                      chatData["lastSender"] != "" &&
                      chatData["lastMessageTime"] != ""
                  ? Message(
                      message: chatData["lastMessage"],
                      senderUID: chatData["lastSender"],
                      time: chatData["lastMessageTime"])
                  : null);
        } else {
          final BabylonUser? otherUser = await UserService.getBabylonUser(
              userUID: List<String>.from(chatData["users"]).firstWhere(
                  (final userListUID) =>
                      userListUID != ConnectedBabylonUser().userUID));
          return Chat(
              chatUID: chatSnapshot.id,
              adminUID: chatData["admin"],
              chatName: otherUser!.fullName,
              iconPath: otherUser.imagePath,
              lastMessage: chatData.containsKey("lastMessage") &&
                      chatData.containsKey("lastMessageTime") &&
                      chatData.containsKey("lastSender") &&
                      chatData["lastMessage"] != "" &&
                      chatData["lastSender"] != "" &&
                      chatData["lastMessageTime"] != ""
                  ? Message(
                      message: chatData["lastMessage"],
                      senderUID: chatData["lastSender"],
                      time: chatData["lastMessageTime"])
                  : null);
        }
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Chat>>? getChatsFromUIDs({
    required final List<String>? chatUIDList,
  }) async {
    try {
      if (chatUIDList != null) {
        final List<Chat> chatList = [];
        await Future.forEach(chatUIDList, (final userUID) async {
          final chat = await getChatFromUID(chatUID: userUID);
          if (chat != null) chatList.add(chat);
        });
        return chatList;
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
