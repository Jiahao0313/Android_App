import "package:babylon_app/models/babylon_user.dart";

class Event {
  // Attributes

  String eventUID;
  String title;
  BabylonUser creator;
  String? place;
  DateTime? date;
  String? fullDescription;
  String? shortDescription;
  String? pictureURL;
  List<BabylonUser>? attendees;
  List<String> attendeesUIDs;

  // Constructors

  Event(
      {required this.eventUID,
      required this.title,
      required this.creator,
      this.place,
      this.date,
      this.fullDescription,
      this.shortDescription,
      this.pictureURL,
      required this.attendeesUIDs,
      this.attendees});
}
