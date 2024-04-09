import "dart:io";
import "package:babylon_app/services/chat/chat_exceptions.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/connection/connections.dart";

class GroupChat extends StatefulWidget {
  const GroupChat({super.key});

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  File? _groupImage;
  String? _error = "";
  final List<String> _usersUID = [];
  final List<BabylonUser> _addedUsers = [];
  List<BabylonUser> _filteredUsers = [];
  List<BabylonUser> _allUsers = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _groupImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildAddedParticipants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Added Participants",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade900,
            ),
          ),
        ),
        ..._addedUsers.map((final user) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.imagePath),
              backgroundColor: Colors.grey.shade200,
            ),
            title: Text(user.fullName, style: TextStyle(fontSize: 16)),
          );
        }),
      ],
    );
  }

  void _showAddParticipantDialog() async {
    if (_allUsers.isEmpty) {
      _allUsers = await UserService.getAllBabylonUsers();
    }
    _filteredUsers = List.from(_allUsers);
    showDialog(
      context: context,
      builder: (final context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: StatefulBuilder(
              builder:
                  (final BuildContext context, final StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(hintText: "Search user..."),
                      onChanged: (final value) {
                        setState(() {
                          _filteredUsers = _allUsers
                              .where((final user) => user.fullName
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                    Expanded(
                      child: _filteredUsers.isEmpty
                          ? Text("No users found")
                          : ListView.separated(
                              itemCount: _filteredUsers.length,
                              separatorBuilder: (final context, final index) =>
                                  Divider(color: Colors.grey.shade400),
                              itemBuilder: (final context, final index) {
                                final user = _filteredUsers[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.imagePath),
                                    backgroundColor: Colors.grey.shade200,
                                  ),
                                  title: Text(user.fullName),
                                  onTap: () {
                                    if (!_usersUID.contains(user.userUID)) {
                                      this.setState(() {
                                        _usersUID.add(user.userUID);
                                        _addedUsers.add(user);
                                      });
                                      Navigator.pop(context);
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
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
            ElevatedButton.icon(
              onPressed: _showAddParticipantDialog,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text("Add People", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            _buildAddedParticipants(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                try {
                  final BabylonUser currUser = ConnectedBabylonUser();
                  ChatException.validateUpdateOrCreateForm(
                      chatName: _groupNameController.text,
                      adminUID: currUser.userUID,
                      chatDescription: _groupDescriptionController.text,
                      image: _groupImage,
                      usersUID: _usersUID);
                  _usersUID.add(currUser.userUID);
                  await ChatService.createChat(
                      chatName: _groupNameController.text,
                      adminUID: currUser.userUID,
                      chatDescription: _groupDescriptionController.text,
                      image: _groupImage,
                      usersUID: _usersUID);
                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (final context) => ConnectionsScreen()));
                } catch (e) {
                  setState(() {
                    _error = e.toString();
                  });
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
                _error ?? "",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
