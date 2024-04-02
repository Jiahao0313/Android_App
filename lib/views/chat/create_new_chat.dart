import "dart:io";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_exceptions.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/views/connection/connections.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  File? _groupImage;
  String? _error = "";
  final List<String> _usersUID = List<String>.empty(growable: true);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _groupImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create New Group Chat"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 80,
                backgroundImage: _groupImage != null
                    ? FileImage(_groupImage!)
                    : AssetImage("assets/group_placeholder.png")
                        as ImageProvider,
                child: _groupImage == null
                    ? Icon(Icons.camera_alt,
                        color: Colors.white.withOpacity(0.7), size: 40)
                    : null,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextButton(
                  onPressed: _pickImage,
                  child: Text("Select a Photo",
                      style: TextStyle(fontSize: 18, color: Colors.green)),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                labelText: "* Group Name",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.group),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _groupDescriptionController,
              decoration: InputDecoration(
                labelText: "Description",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Add People",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.person_add),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                      icon: Icon(Icons.add_circle_outline,
                          size: 40, color: Colors.green),
                      onPressed: () async {
                        // add user
                      }),
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  final BabylonUser currUser = ConnectedBabylonUser();
                  _usersUID.add(currUser.userUID);
                  ChatException.validateUpdateOrCreateForm(
                      chatName: _groupNameController.text,
                      adminUID: currUser.userUID,
                      chatDescription: _groupDescriptionController.text,
                      image: _groupImage,
                      usersUID: _usersUID);
                  await ChatService.createChat(
                      chatName: _groupNameController.text,
                      adminUID: currUser.userUID,
                      chatDescription: _groupDescriptionController.text,
                      image: _groupImage,
                      usersUID: _usersUID);
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (final context) => const ConnectionsScreen()),
                  );
                } catch (e) {
                  if (e is FirebaseAuthException) {
                    setState(() {
                      _error = e.message;
                    });
                  } else {
                    setState(() {
                      _error = e.toString();
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text("Create", style: TextStyle(fontSize: 20)),
            ),
            Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                )),
          ],
        ),
      ),
    );
  }
}
