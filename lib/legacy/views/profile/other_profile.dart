import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/utils/datetime_utils.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/legacy/views/chat/chat_view.dart";
import "package:flutter/material.dart";
import "package:babylon_app/legacy/views/profile/full_screen_image.dart";

class OtherProfile extends StatefulWidget {
  final BabylonUser babylonUser;
  const OtherProfile({super.key, required this.babylonUser});

  @override
  OtherProfileState createState() => OtherProfileState(babylonUser);
}

class OtherProfileState extends State<OtherProfile> {
  final BabylonUser babylonUser;

  OtherProfileState(this.babylonUser);

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile"),
        backgroundColor: Colors.green, // AppBar background color.
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            GestureDetector(
              // Tapping on the profile picture opens the FullScreenImage view.
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (final _) => FullScreenImage(
                        imagePath: babylonUser.imagePath,
                        name: babylonUser.fullName)),
              ),
              child: ImageLoader.loadProfilePicture(babylonUser.imagePath, 60),
            ),
            SizedBox(height: 10),
            Text(babylonUser.fullName,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold)), // Display user"s name.
            Text(
                "${DatetimeUtils.age(DateTime.parse(babylonUser.dateOfBirth!))} years old, from ${babylonUser.originCountry}",
                style: TextStyle(
                    fontSize: 18,
                    fontStyle:
                        FontStyle.italic)), // Display user"s age and country.
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                  "${babylonUser.about}", // TODO(EnzoL): Make some fields like "about" mandatory to avoid display issues
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16)), // Display user"s about section.
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Button to send a friend request.
                ElevatedButton.icon(
                  icon: Icon(Icons.person_add),
                  label: Text("Add Friend"),
                  onPressed: () {
                    setState(() {
                      UserService.sendConnectionRequest(
                          requestUID: babylonUser.userUID);
                      UserService.setUpConnectedBabylonUser(
                          userUID: ConnectedBabylonUser().userUID);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue),
                ),
                // Button to start a chat.
                ElevatedButton.icon(
                  icon: Icon(Icons.chat),
                  label: Text("Chat"),
                  onPressed: () async {
                    final Chat? newChat =
                        await ChatService.createChat(otherUser: babylonUser);
                    if (newChat != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (final context) => ChatView(
                                  chat: newChat,
                                )),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
