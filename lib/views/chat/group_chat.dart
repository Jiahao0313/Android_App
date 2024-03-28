import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/message.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/views/chat/group_chat_info.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

// Main widget for the group chat, enhanced for better UI and UX
class GroupChatView extends StatefulWidget {
  final Chat chat;
  const GroupChatView({super.key, required this.chat});

  @override
  _GroupChatViewState createState() => _GroupChatViewState(chat);
}

class _GroupChatViewState extends State<GroupChatView> {
  final Chat chat;
  _GroupChatViewState(this.chat);
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsersData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void fetchUsersData() async {
    final users = await ChatService.getChatUsers(chatUID: chat.chatUID);
    setState(() async {
      chat.users = users;
    });
  }

  // Handles sending a message
  void _sendMessage() {
    ChatService.sendMessage(
        chatUID: chat.chatUID,
        message: Message(
            message: _messageController.text.trim(),
            senderUID: ConnectedBabylonUser().userUID,
            time: Timestamp.now()));

    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(chat.chatName!),
            backgroundColor: Colors.green,
            actions: [
              IconButton(
                icon: Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (final context) => GroupChatInfo()),
                  );
                },
              )
            ]),
        body: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: _buildMessageStream(),
              ),
            ),
            _buildMessageInputField(),
          ],
        ));
  }

  Widget _buildMessageStream() {
    return StreamBuilder<List<Message>>(
        stream: ChatService.getChatStream(chatUID: chat.chatUID).stream,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.hasError) return Text("Something went wrong");
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }
          return ListView(
            reverse: true,
            children: [
              ...snapshot.data!
                  .map((final aMessage) => _buildMessageTile(aMessage))
            ],
          );
        });
  }

  // Builds a single message tile with enhanced UI
  Widget _buildMessageTile(final Message message) {
    final BabylonUser user =
        chat.users!.firstWhere((anUser) => anUser.userUID == message.senderUID);
    final bool isCurrentUser = message.senderUID ==
        ConnectedBabylonUser()
            .userUID; // Check if the message is from the current user
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) // Only show profile picture for other users
            CircleAvatar(
              backgroundImage: NetworkImage(user.imagePath),
            ),
          if (!isCurrentUser) // Add spacing only if the profile picture is displayed
            SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser) // Only show the user's name for other users
                  Text(
                    user.fullName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.green[50] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.message!,
                        style: TextStyle(fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "${DateFormat("dd MMMM yyyy").format(message.time!.toDate())} at ${DateFormat("hh:mm aaa").format(message.time!.toDate())}",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Builds the message input field with enhanced UX
  Widget _buildMessageInputField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
