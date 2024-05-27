import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/event.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class BabylonUser {
  // Attributes

  String userUID = "";
  String fullName = "";
  String email = "";
  String imagePath = "";
  String? dateOfBirth;
  String? originCountry;
  String? about;
  Timestamp? creationTime;

  List<Event>? listedEvents = [];
  List<String> listedEventsUIDs = [];

  List<BabylonUser>? listedConnections = [];
  List<String> listedConnectionsUIDs = [];

  List<BabylonUser>? connectionRequests = [];
  List<String> connectionRequestsUIDs = [];

  List<BabylonUser>? sentPendingConnectionRequests = [];
  List<String> sentPendingConnectionRequestsUIDs = [];

  List<Chat>? groupChatInvitations = [];
  List<String> groupChatInvitationsUIDs = [];

  List<Chat>? groupChatJoinRequests = [];
  List<String> groupChatJoinRequestsUIDs = [];

  // Constructors

  BabylonUser();
  BabylonUser.withData(
      {required this.userUID,
      required this.fullName,
      required this.email,
      required this.imagePath,
      this.dateOfBirth,
      this.originCountry,
      this.about,
      required this.creationTime,
      this.listedEvents,
      required this.listedEventsUIDs,
      this.listedConnections,
      required this.listedConnectionsUIDs,
      this.connectionRequests,
      required this.connectionRequestsUIDs,
      this.sentPendingConnectionRequests,
      required this.sentPendingConnectionRequestsUIDs,
      this.groupChatInvitations,
      required this.groupChatInvitationsUIDs,
      this.groupChatJoinRequests,
      required this.groupChatJoinRequestsUIDs});
}
