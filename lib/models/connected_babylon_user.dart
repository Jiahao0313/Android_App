import "package:babylon_app/models/babylon_user.dart";

// Singleton class -> we can have only one user connected so we can manage the instance properly

class ConnectedBabylonUser extends BabylonUser {
  // Attributes
  List<String> listedRequests = [];

  // Intern constructor
  ConnectedBabylonUser._internal() : super();

  static final ConnectedBabylonUser _instance =
      ConnectedBabylonUser._internal();

  // Factory -> it helps you to use the same instance of ConnectedBabylonUser
  factory ConnectedBabylonUser() => _instance;

  static Future<void> setConnectedBabylonUser(
      final BabylonUser? babylonUser) async {
    _instance.imagePath = babylonUser!.imagePath;
    _instance.email = babylonUser.email;
    _instance.fullName = babylonUser.fullName;
    _instance.dateOfBirth = babylonUser.dateOfBirth;
    _instance.originCountry = babylonUser.originCountry;
    _instance.about = babylonUser.about;
    _instance.listedEvents = babylonUser.listedEvents;
    _instance.userUID = babylonUser.userUID;
    _instance.listedConnections = babylonUser.listedConnections;
  }

  static Future<void> setRequests(final List<String> requests) async {
    _instance.listedRequests = requests;
  }
}
