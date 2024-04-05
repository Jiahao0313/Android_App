import "package:babylon_app/models/babylon_user.dart";

class Event {
  // Attributes

  String eventUID;
  String title;
  String? place;
  DateTime? date;
  String? fullDescription;
  String? shortDescription;
  String? pictureURL;

  BabylonUser? creator;
  String creatorUID;

  List<BabylonUser>? attendees;
  List<String>? attendeesUIDs = [];

  // Constructors

  Event(
      {required this.eventUID,
      required this.title,
      this.place,
      this.date,
      this.fullDescription,
      this.shortDescription,
      this.pictureURL,
      required this.creatorUID,
      this.creator,
      this.attendeesUIDs,
      this.attendees});
}
