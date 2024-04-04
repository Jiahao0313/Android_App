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
  List<BabylonUser> attendees;

  // Constructors

  Event(
      {required this.eventDocumentID,
      required this.title,
      this.creator,
      this.place,
      this.date,
      this.fullDescription,
      this.shortDescription,
      this.pictureURL,
      required this.attendees});

  static Future<Event?> create(
      {required final String newEventDocumentID,
      required final String newTitle,
      required final String babylonUserUID,
      final String? newPlace,
      final DateTime? newDate,
      final String? newFullDescription,
      final String? newShortDescription,
      final String? newPictureURL,
      final List<String>? attendeeIDs}) async {
    try {
      List<BabylonUser> attendees = [];
      final BabylonUser? user =
          await UserService.getBabylonUser(userUID: babylonUserUID);
      if (user != null) {
        attendees =
            await UserService.getBabylonUsersFromUIDs(userUIDList: attendeeIDs);
        return Event(
            eventDocumentID: newEventDocumentID,
            title: newTitle,
            creator: user,
            place: newPlace,
            date: newDate,
            fullDescription: newFullDescription,
            shortDescription: newShortDescription,
            pictureURL: newPictureURL,
            attendees: attendees);
      } else {
        return null;
      }
    } catch (e) {
      rethrow;
    }
  }
}
