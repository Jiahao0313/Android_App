// my_friends.dart
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:flutter/material.dart";

class MyFriends extends StatefulWidget {
  const MyFriends({super.key});

  @override
  MyFriendsState createState() => MyFriendsState();
}

class MyFriendsState extends State<MyFriends> {
  Future<List<BabylonUser?>> _requests = UserService.getConnectionsRequests();
  Future<List<BabylonUser?>> _connections = UserService.getConnections();

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
            _buildRequestsList(context),
            _buildSectionTitle("My Friends"),
            _buildConnectionsList(context),
          ],
        ),
      ),
    );
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

  Widget _buildRequestsList(final BuildContext context) {
    return FutureBuilder(
        future: _requests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<BabylonUser?>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final babylonUser) =>
                  _buildRequestTile(context, babylonUser))
            ];
          } else {
            children = <Widget>[];
          }
          return Column(
            children: children,
          );
        });
  }

  Widget _buildRequestTile(
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
                UserService.sendConnectionRequest(requestUID: request.userUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _connections = UserService.getConnections();
                _requests = UserService.getConnectionsRequests();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              // Cancel join request action
              setState(() {
                UserService.removeConnectionRequest(
                    requestUID: request.userUID);
                UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID);
                _requests = UserService.getConnectionsRequests();
              });
            },
          ),
        ],
      ),
    );
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
                  UserService.removeConnectionToUser(
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
