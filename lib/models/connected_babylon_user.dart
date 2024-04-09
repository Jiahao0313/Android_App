import "package:babylon_app/models/babylon_user.dart";

// Singleton class -> we can have only one user connected so we can manage the instance properly

class ConnectedBabylonUser extends BabylonUser {
  // Intern constructor
  ConnectedBabylonUser._internal() : super();

  static final ConnectedBabylonUser _instance =
      ConnectedBabylonUser._internal();

  // Factory -> it helps you to use the same instance of ConnectedBabylonUser
  factory ConnectedBabylonUser() => _instance;

  static Future<void> setConnectedBabylonUser(
      {required final BabylonUser babylonUser}) async {
    _instance.userUID = babylonUser.userUID;
    _instance.fullName = babylonUser.fullName;
    _instance.email = babylonUser.email;
    _instance.imagePath = babylonUser.imagePath;
    _instance.dateOfBirth = babylonUser.dateOfBirth;
    _instance.originCountry = babylonUser.originCountry;
    _instance.about = babylonUser.about;
    _instance.creationTime = babylonUser.creationTime;
    _instance.listedEventsUIDs = babylonUser.listedEventsUIDs;
    _instance.listedConnectionsUIDs = babylonUser.listedConnectionsUIDs;
    _instance.connectionRequestsUIDs = babylonUser.connectionRequestsUIDs;
    _instance.sentPendingConnectionRequestsUIDs =
        babylonUser.sentPendingConnectionRequestsUIDs;
    _instance.groupChatInvitationsUIDs = babylonUser.groupChatInvitationsUIDs;
    _instance.groupChatInvitationsUIDs = babylonUser.groupChatJoinRequestsUIDs;
  }
}
