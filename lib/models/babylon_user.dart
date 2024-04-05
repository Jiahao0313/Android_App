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

  List<BabylonUser>? conectionRequests = [];
  List<String>? conectionRequestsUIDs = [];

  List<BabylonUser>? listedConnections = [];
  List<String>? listedConnectionsUIDs = [];

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
      this.conectionRequests,
      this.conectionRequestsUIDs});
}
