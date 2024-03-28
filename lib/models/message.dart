import "package:babylon_app/models/babylon_user.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class Message {
  String? messageDocumentID;
  String? message;
  String? senderUID;
  Timestamp? time;

  Message({this.messageDocumentID, this.senderUID, this.message, this.time});
}
