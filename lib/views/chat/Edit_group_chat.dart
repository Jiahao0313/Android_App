import "dart:io";
import "package:babylon_app/models/chat.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:babylon_app/services/chat/chat_service.dart";

class EditGroupChatScreen extends StatefulWidget {
  final Chat chat;

  const EditGroupChatScreen({super.key, required this.chat});

  @override
  _EditGroupChatScreenState createState() => _EditGroupChatScreenState(chat: chat);
}

class _EditGroupChatScreenState extends State<EditGroupChatScreen> {
  final Chat chat;
  File? _image;

  _EditGroupChatScreenState({required this.chat});

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {

    if (chat.chatName == null || chat.chatName!.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Group name is required")));
      return;
    }

    try {
      await ChatService.updateGroupChat(
        chatUID: widget.chat.chatUID,
        chatName: widget.chat.chatName,
        chatDescription: widget.chat.chatDescription,
        image: _image,
      );

      setState(() {
        if (_image != null) {
          widget.chat.iconPath = _image!.path;
        }
      });

      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save changes: $e")));
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Group Chat Info"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(File(_image!.path))
                    : (widget.chat.iconPath != null && widget.chat.iconPath!.isNotEmpty
                    ? NetworkImage(widget.chat.iconPath!)
                    : AssetImage("assets/default_group_image.png")) as ImageProvider<Object>,
                child: Icon(Icons.edit, size: 50, color: Colors.white.withOpacity(0.7)),
              ),),       SizedBox(height: 20),
            TextFormField(
              initialValue: chat.chatName,
              decoration: InputDecoration(labelText: "Group Name"),
              onChanged: (final value) => chat.chatName = value,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: chat.chatDescription,
              decoration: InputDecoration(labelText: "Group Description"),
              onChanged: (final value) => chat.chatDescription = value,
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
