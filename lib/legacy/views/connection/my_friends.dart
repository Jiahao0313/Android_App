// my_friends.dart
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:flutter/material.dart";

class MyFriends extends StatefulWidget {
  const MyFriends({super.key});

  @override
  MyFriendsState createState() => MyFriendsState();
}

class MyFriendsState extends State<MyFriends> {
  Future<List<BabylonUser>> _connectionsRequests =
      UserService.getConnectionsRequests();
  Future<List<BabylonUser>> _sentConnectionsRequests =
      UserService.getSentPendingConnectionsRequests();
  Future<List<BabylonUser>> _connections = UserService.getConnections();
  Future<List<Chat>> _groupChatJoinRequests =
      UserService.getGroupChatJoinRequests(
          userUID: ConnectedBabylonUser().userUID);
  Future<List<Chat>> _groupChatInvitationRequests =
      UserService.getGroupChatInvitations(
          userUID: ConnectedBabylonUser().userUID);

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Friends"),
        backgroundColor: Colors.green, // Updated color for a fresh look
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionTitle("Friend Requests"),
            _buildConnectionRequestsList(context),
            _buildSectionTitle("Pending sent friend requests"),
            _buildPendingSentConnectionRequestsList(context),
            _buildSectionTitle("My Friends"),
            _buildConnectionsList(context),
            _buildSectionTitle("Group chat invitations"),
            _buildGroupChatInvitationsList(context),
            _buildSectionTitle("Group chat join requests"),
            _buildGroupChatJoinRequestsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionRequestsList(final BuildContext context) {
    return FutureBuilder(
        future: _connectionsRequests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<BabylonUser?>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final babylonUser) =>
                  _buildConnectionRequestTile(context, babylonUser))
            ];
          } else {
            children = <Widget>[];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildPendingSentConnectionRequestsList(final BuildContext context) {
    return FutureBuilder(
        future: _sentConnectionsRequests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<BabylonUser>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final user) =>
                  _buildSentConnectionRequestTile(context, user))
            ];
          } else {
            children = <Widget>[];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildGroupChatInvitationsList(final BuildContext context) {
    return FutureBuilder(
        future: _groupChatInvitationRequests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<Chat>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final chat) =>
                  _buildsentGroupChatInvitationTile(context, chat))
            ];
          } else {
            children = <Widget>[];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildGroupChatJoinRequestsList(final BuildContext context) {
    return FutureBuilder(
        future: _groupChatJoinRequests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<Chat>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map(
                  (final chat) => _buildGroupChatJoinRequestTile(context, chat))
            ];
          } else {
            children = <Widget>[];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildConnectionsList(final BuildContext context) {
    return FutureBuilder<List<BabylonUser?>>(
        future: _connections,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<BabylonUser?>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final babylonUser) =>
                  _buildConnectionTile(context, babylonUser))
            ];
          } else {
            children = <Widget>[
              Text("There is not a lot of people around here ... 😴")
            ];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildSectionTitle(final String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900),
        ),
      ),
    );
  }

  Widget _buildConnectionRequestTile(
      final BuildContext context, final BabylonUser? request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(request!.imagePath),
      ),
      title: Text(request.fullName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              // Accept join request action
              setState(() {
                UserService.acceptConnectionRequest(
                    requestUID: request.userUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _connections = UserService.getConnections();
                _connectionsRequests = UserService.getConnectionsRequests();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              // Cancel join request action
              setState(() {
                UserService.cancelConnectionRequest(
                    requestUID: request.userUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _connectionsRequests = UserService.getConnectionsRequests();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSentConnectionRequestTile(
      final BuildContext context, final BabylonUser request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(request.imagePath),
      ),
      title: Text(request.fullName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              // Cancel join request action
              try {
                // await UserService.cancelGroupChatInvitation(
                //     chatUID: chat.chatUID, userUID: user.userUID);
                setState(() {
                  UserService.setUpConnectedBabylonUser(
                      userUID: ConnectedBabylonUser().userUID);
                  _sentConnectionsRequests =
                      UserService.getSentPendingConnectionsRequests();
                });
              } catch (e) {
                rethrow;
              }
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupChatJoinRequestTile(
      final BuildContext context, final Chat request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(request.iconPath!),
      ),
      title: Text(request.chatName!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () async {
              // Cancel groupchat join request action
              try {
                await ChatService.removeGroupChatJoinRequest(
                    chatUID: request.chatUID,
                    userUID: ConnectedBabylonUser().userUID);
                setState(() {
                  UserService.setUpConnectedBabylonUser(
                      userUID: ConnectedBabylonUser().userUID);
                  _groupChatJoinRequests = UserService.getGroupChatJoinRequests(
                      userUID: ConnectedBabylonUser().userUID);
                });
              } catch (e) {
                rethrow;
              }
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildsentGroupChatInvitationTile(
      final BuildContext context, final Chat request) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(request.iconPath!),
      ),
      title: Text(request.chatName!),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              // Accept join request action
              setState(() {
                ChatService.acceptGroupChatInvitation(
                    userUID: ConnectedBabylonUser().userUID,
                    chatUID: request.chatUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _groupChatInvitationRequests =
                    UserService.getGroupChatInvitations(
                        userUID: ConnectedBabylonUser().userUID);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              // Cancel join request action
              setState(() {
                ChatService.removeGroupChatInvitation(
                    userUID: ConnectedBabylonUser().userUID,
                    chatUID: request.chatUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _groupChatInvitationRequests =
                    UserService.getGroupChatInvitations(
                        userUID: ConnectedBabylonUser().userUID);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTile(
      final BuildContext context, final BabylonUser? babylonUser) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(babylonUser!.imagePath),
      ),
      title: Text(babylonUser.fullName),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2)),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              // Show confirmation dialog when removing a connection
              _showRemoveConnectionDialog(context, babylonUser);
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveConnectionDialog(
      final BuildContext context, final BabylonUser connection) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text("Remove a Friend"),
          content: Text(
              "Are you sure you want to remove ${connection.fullName} from your friends?"),
          actions: <Widget>[
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                setState(() {
                  UserService.removeConnection(
                      connectionUID: connection.userUID);
                  UserService.setUpConnectedBabylonUser(
                      userUID: ConnectedBabylonUser().userUID);
                  _connections = UserService.getConnections();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
