import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/profile/other_profile.dart";
import "package:flutter/material.dart";

class ChatInfoView extends StatefulWidget {
  final Chat chat;
  const ChatInfoView({super.key, required this.chat});

  @override
  _ChatInfoViewState createState() => _ChatInfoViewState(chat: chat);
}

class _ChatInfoViewState extends State<ChatInfoView> {
  final Chat chat;
  bool isAdmin = false;
  _ChatInfoViewState({required this.chat});
  List<BabylonUser> joiningRequests = [];
  List<BabylonUser> invitations = [];
  bool hasUsersLoaded = false;

  @override
  void initState() {
    super.initState();
    fetchUsersData();
    setState(() {
      isAdmin = chat.adminUID == ConnectedBabylonUser().userUID;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchUsersData() async {
    final users = await ChatService.getChatUsers(chatUID: chat.chatUID);
    final List<BabylonUser> joiningRequestsData =
        await UserService.getBabylonUsersFromUIDs(
            userUIDList: chat.joiningRequests);
    final List<BabylonUser> sentInvitationsData =
        await UserService.getBabylonUsersFromUIDs(
            userUIDList: chat.sentInvitations);
    setState(() {
      chat.users = users;
      hasUsersLoaded = true;
      joiningRequests = joiningRequestsData;
      invitations = sentInvitationsData;
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chat.chatName != "" && chat.chatName != null
            ? chat.chatName!
            : "Chat info"),
        backgroundColor: Colors.green, // Updated color for a fresh look
      ),
      body: hasUsersLoaded
          ? SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      children: [
                        Text(
                          chat.chatName != "" && chat.chatName != null
                              ? chat.chatName!
                              : "Chat info",
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
                  if (isAdmin)
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Add participant action
                        try {
                          await ChatService.sendGroupChatInvitation(
                              chatUID: chat.chatUID,
                              userUID: "oAxwoYTb52RsCXO1KWWAC12ONz82");
                          setState(() {
                            invitations.add(chat.users![0]);
                          });
                        } catch (e) {
                          rethrow;
                        }
                      },
                      icon: Icon(Icons.add, color: Colors.white),
                      label: Text("Add Participant",
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  if (isAdmin) _buildSectionTitle("Join Requests"),
                  if (isAdmin) _buildJoinRequestsList(),
                  if (isAdmin) _buildSectionTitle("Sent invitations"),
                  if (isAdmin) _buildSentInvitationsList(),
                  _buildSectionTitle("Participants"),
                  _buildParticipantsList(context),
                  if (isAdmin) _buildSectionTitle("Banned participants"),
                  if (isAdmin) _buildBannedParticipantsList(context),
                ],
              ),
            )
          : null,
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
      children: joiningRequests
          .map((final user) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imagePath),
                ),
                title: Text(user.fullName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin)
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          // Accept join request action
                          try {
                            await ChatService.acceptGroupChatJoinRequest(
                                chatUID: chat.chatUID, userUID: user.userUID);
                            setState(() {
                              joiningRequests.removeWhere((final anUser) =>
                                  anUser.userUID == user.userUID);
                              chat.users!.add(user);
                            });
                          } catch (e) {
                            rethrow;
                          }
                        },
                      ),
                    if (isAdmin)
                      IconButton(
                        icon: Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          // decline join request action
                          try {
                            await ChatService.declineGroupChatJoinRequest(
                                chatUID: chat.chatUID, userUID: user.userUID);
                            setState(() {
                              joiningRequests.removeWhere((final anUser) =>
                                  anUser.userUID == user.userUID);
                            });
                          } catch (e) {
                            rethrow;
                          }
                        },
                      ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSentInvitationsList() {
    return Column(
      children: invitations
          .map((final user) => ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imagePath),
                ),
                title: Text(user.fullName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin)
                      InkWell(
                        onTap: () async {
                          // Cancel join request action
                          try {
                            await ChatService.cancelGroupChatInvitation(
                                chatUID: chat.chatUID, userUID: user.userUID);
                            setState(() {
                              invitations.removeWhere((final anUser) =>
                                  anUser.userUID == user.userUID);
                            });
                          } catch (e) {
                            rethrow;
                          }
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      )
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
          leading: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (final context) => OtherProfile(babylonUser: user)),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.imagePath),
            ),
          ),
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
          leading: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (final context) => OtherProfile(babylonUser: user)),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.imagePath),
            ),
          ),
          title: Text(user.fullName),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
