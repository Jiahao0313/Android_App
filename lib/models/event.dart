import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/services/user/user_service.dart";

class Event {
  // Attributes

  String eventDocumentID;
  String? title;
  BabylonUser? creator;
  String? place;
  DateTime? date;
  String? fullDescription;
  String? shortDescription;
  String? pictureURL;
  List<BabylonUser?> attendees = [];

  // Constructors

  Event(
      final String newEventDocumentID,
      final String newTitle,
      final BabylonUser? newCreator,
      final String? newPlace,
      final DateTime? newDate,
      final String? newFullDescription,
      final String? newShortDescription,
      final String? newPictureURL,
      final List<BabylonUser?> newAttendees)
      : eventDocumentID = newEventDocumentID,
        title = newTitle,
        creator = newCreator,
        place = newPlace,
        date = newDate,
        fullDescription = newFullDescription,
        shortDescription = newShortDescription,
        pictureURL = newPictureURL,
        attendees = newAttendees;

  static Future<Event> create(
      final String newEventDocumentID,
      final String newTitle,
      final String babylonUserUID,
      final String? newPlace,
      final DateTime? newDate,
      final String? newFullDescription,
      final String? newShortDescription,
      final String? newPictureURL,
      final List<String> attendeeIDs) async {
    final BabylonUser? user =
        await UserService.getBabylonUser(userUID: babylonUserUID);
    final List<BabylonUser?> attendees = List.empty(growable: true);
    await Future.forEach(attendeeIDs, (final attendee) async {
      attendees.add(await UserService.getBabylonUser(userUID: attendee));
    });
    return Event(newEventDocumentID, newTitle, user, newPlace, newDate,
        newFullDescription, newShortDescription, newPictureURL, attendees);
  }
}
