import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/message.dart";

class Chat {
  String chatUID;
  Message? lastMessage;
  String? adminUID;
  String? iconPath;
  String? chatName;
  List<BabylonUser>? users;
  List<String>? bannedUsersUID;
  List<String>? sentInvitations;
  List<String>? joiningRequests;

  Chat(
      {required this.chatUID,
      this.chatName,
      this.adminUID,
      this.lastMessage,
      this.iconPath,
      this.bannedUsersUID,
      this.sentInvitations,
      this.joiningRequests});
}
