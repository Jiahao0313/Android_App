import "dart:async";

import "dart:io";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/message.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
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
        newChatData["users"] =
            FieldValue.arrayUnion([curr.userUID, otherUser.userUID]);
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
      }
      await db.collection("chats").doc().set(newChatData);
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
        final chatData = snapShot.data();

        //if is groupchat (has admin)
        if (chatData.containsKey("admin") && chatData["admin"] != "") {
          final imageUrl = await FirebaseStorage.instance
              .ref()
              .child(chatData["iconPath"])
              .getDownloadURL();

          res.add(Chat(
              chatUID: snapShot.id,
              adminUID: chatData["admin"],
              chatName: chatData["chatName"],
              iconPath: imageUrl,
              bannedUsersUID: chatData.containsKey("bannedUsers")
                  ? List<String>.from(chatData["bannedUsers"])
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
                  : null));
        } else {
          final BabylonUser? otherUser = await UserService.getBabylonUser(
              List<String>.from(chatData["users"])
                  .firstWhere((final userListUID) => userListUID != userUID));
          res.add(Chat(
              chatUID: snapShot.id,
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
                  : null));
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
      await Future.forEach(userIDList, (userID) async {
        res.add((await UserService.getBabylonUser(userID))!);
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

  static Future<void> removeUserToGroupChatBanList(
      {required final String userUID, required final String chatUID}) async {
    try {
      await FirebaseFirestore.instance.collection("chats").doc(chatUID).update({
        "bannedUsers": FieldValue.arrayUnion([userUID])
      });
    } catch (e) {
      rethrow;
    }
  }
}
