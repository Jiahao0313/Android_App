import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:flutter/material.dart";

class GroupChatInfoView extends StatefulWidget {
  final Chat chat;
  const GroupChatInfoView({super.key, required this.chat});

  @override
  _GroupChatInfoViewState createState() => _GroupChatInfoViewState(chat: chat);
}

class _GroupChatInfoViewState extends State<GroupChatInfoView> {
  final Chat chat;
  bool isAdmin = false;
  _GroupChatInfoViewState({required this.chat});

  @override
  void initState() {
    super.initState();

    setState(() {
      isAdmin = chat.adminUID == ConnectedBabylonUser().userUID;
    });
  }

  final List<Map<String, String>> joinRequests = List.generate(
    3,
    (final index) => {
      "name": "Request ${index + 1}",
      "profilePic": "assets/images/default_user_logo.png"
    },
  );

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Chat Info"),
        backgroundColor: Colors.green, // Updated color for a fresh look
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                children: [
                  Text(
                    "Group Info",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade900),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This group is for testing the group chat!",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Add participant action
              },
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add Participant",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            _buildSectionTitle("Join Requests"),
            _buildJoinRequestsList(),
            _buildSectionTitle("Participants"),
            _buildParticipantsList(context),
            _buildSectionTitle("Banned participants"),
            _buildBannedParticipantsList(context),
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

  Widget _buildJoinRequestsList() {
    return Column(
      children: joinRequests
          .map((final request) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(request["profilePic"]!),
                ),
                title: Text(request["name"]!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin)
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () {
                          // Accept join request action
                        },
                      ),
                    if (isAdmin)
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          // Cancel join request action
                        },
                      ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildParticipantsList(final BuildContext context) {
    return Column(
      children: chat.users!.map((final user) {
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.imagePath)),
          title: Text(user.fullName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.userUID ==
                  chat.adminUID) // Assuming the first user is the admin
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Admin",
                    style: TextStyle(
                        color: Colors.green.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              if (isAdmin)
                InkWell(
                  onTap: () {
                    // Show confirmation dialog when removing a participant
                    _showBanParticipantDialog(context, user, chat.chatUID);
                  },
                  child: Text(
                    "Ban",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBannedParticipantsList(final BuildContext context) {
    final List<BabylonUser> bannedUsers = chat.bannedUsersUID!
        .map((final aBannedUserUID) => chat.users!
            .firstWhere((final aUser) => aUser.userUID == aBannedUserUID))
        .toList();
    return Column(
      children: bannedUsers.map((final user) {
        return ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(user.imagePath)),
          title: Text(user.fullName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin)
                InkWell(
                  onTap: () {
                    // Show confirmation dialog when removing a participant
                    _showUnanParticipantDialog(context, user, chat.chatUID);
                  },
                  child: Text(
                    "Unban",
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                )
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showBanParticipantDialog(final BuildContext context,
      final BabylonUser participant, final String chatUID) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text("Ban Participant"),
          content: Text(
              "Are you sure you want to ban ${participant.fullName} from the group?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                ChatService.addUserToGroupChatBanList(
                    userUID: participant.userUID, chatUID: chatUID);
                if (!chat.bannedUsersUID!.contains(participant.userUID)) {
                  setState(() {
                    chat.bannedUsersUID = [
                      ...chat.bannedUsersUID!,
                      participant.userUID
                    ];
                  });
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showUnanParticipantDialog(final BuildContext context,
      final BabylonUser participant, final String chatUID) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text("Unnan Participant"),
          content: Text(
              "Are you sure you want to unban ${participant.fullName} from the group?"),
          actions: <Widget>[
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                ChatService.removeUserOfGroupChatBanList(
                    userUID: participant.userUID, chatUID: chatUID);
                setState(() {
                  chat.bannedUsersUID = chat.bannedUsersUID!
                      .where((final aBannedUID) =>
                          aBannedUID != participant.userUID)
                      .toList();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
