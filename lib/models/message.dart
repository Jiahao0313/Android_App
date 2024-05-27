import "package:babylon_app/models/babylon_user.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class Message {
  String? messageUID;
  String message;
  Timestamp time;

  BabylonUser? sender;
  String senderUID;

  Message({
    this.messageUID,
    required this.message,
    required this.time,
    this.sender,
    required this.senderUID,
  });
}
