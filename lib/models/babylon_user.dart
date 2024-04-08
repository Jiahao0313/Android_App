import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/event.dart";

class BabylonUser {
  // Attributes

  String userUID = "";
  String fullName = "";
  String email = "";
  String imagePath = "";
  String? dateOfBirth;
  String? originCountry;
  String? about;

  List<Event>? listedEvents = [];
  List<String>? listedEventsUIDs = [];

  List<BabylonUser>? listedConnections = [];
  List<String>? listedConnectionsUIDs = [];

  List<BabylonUser>? connectionRequests = [];
  List<String>? connectionRequestsUIDs = [];

  List<BabylonUser>? sentPendingConnectionRequests = [];
  List<String>? sentPendingConnectionRequestsUIDs = [];

  List<Chat>? groupChatInvitations = [];
  List<String>? groupChatInvitationsUIDs = [];

  List<Chat>? groupChatJoinRequests = [];
  List<String>? groupChatJoinRequestsUIDs = [];

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
      this.listedEvents,
      this.listedEventsUIDs,
      this.listedConnections,
      this.listedConnectionsUIDs,
      this.connectionRequests,
      this.connectionRequestsUIDs,
      this.sentPendingConnectionRequests,
      this.sentPendingConnectionRequestsUIDs,
      this.groupChatInvitations,
      this.groupChatInvitationsUIDs,
      this.groupChatJoinRequests,
      this.groupChatJoinRequestsUIDs});
}
