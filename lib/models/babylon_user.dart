class BabylonUser {
  // Attributes

  String userUID = "";
  String fullName = "";
  String email = "";
  String? dateOfBirth;
  String? originCountry;
  String? about;
  String imagePath = "";
  List<String>? listedEvents = [];
  List<String>? listedConnections = [];
  List<String>? friendRequests = [];


  // Constructors

  BabylonUser();
  BabylonUser.withData(
      {required this.userUID,
      required this.fullName,
      required this.email,
      this.about,
      this.originCountry,
      this.dateOfBirth,
      required this.imagePath,
      this.listedEvents,
      this.listedConnections,
      required this.friendRequests});
}
