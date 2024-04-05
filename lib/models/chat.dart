import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/message.dart";

class Chat {
  String chatUID;
  String? chatName;
  String? adminUID;
  String? iconPath;
  Message? lastMessage;

  List<BabylonUser>? users = [];
  List<String> usersUIDs = [];

  List<BabylonUser>? bannedUsers = [];
  List<String>? bannedUsersUIDs = [];

  List<BabylonUser>? sentInvitations = [];
  List<String>? sentInvitationsUIDs = [];

  List<BabylonUser>? joiningRequests = [];
  List<String>? joiningRequestsUIDs = [];

  Chat(
      {required this.chatUID,
      this.chatName,
      this.adminUID,
      this.iconPath,
      this.lastMessage,
      this.users,
      required this.usersUIDs,
      this.bannedUsers,
      this.bannedUsersUIDs,
      this.sentInvitations,
      this.sentInvitationsUIDs,
      this.joiningRequests,
      this.joiningRequestsUIDs});
}
