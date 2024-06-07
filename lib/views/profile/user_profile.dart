import "package:babylon_app/legacy/views/chat/chat_view.dart";
import "package:babylon_app/legacy/views/profile/full_screen_image.dart";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/utils/datetime_utils.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";

class UserProfileDialog extends StatelessWidget {
  final BabylonUser user;

  const UserProfileDialog({super.key, required this.user});

  @override
  Widget build(final BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.green),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (final _) => FullScreenImage(
                    imagePath: user.imagePath,
                    name: user.fullName,
                  ),
                ),
              ),
              child: ImageLoader.loadProfilePicture(user.imagePath, 60),
            ),
            SizedBox(height: 20),
            Text(
              user.fullName,
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "from ${user.originCountry}",
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              "${DatetimeUtils.age(DateTime.parse(user.dateOfBirth!))} years old",
                style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 30),
            Text(
              "About me",
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: Text(
                "${user.about}",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    UserService.sendConnectionRequest(
                      requestUID: user.userUID,
                    );
                    UserService.setUpConnectedBabylonUser(
                      userUID: ConnectedBabylonUser().userUID,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.person_add),
                      Text("Add Friend",
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                    ]),
                ),
                
                ElevatedButton(
                  onPressed: () async {
                    final Chat? newChat = await ChatService.createChat(
                      otherUser: user,
                    );
                    if (newChat != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (final context) => ChatView(
                            chat: newChat,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    backgroundColor: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Icon(Icons.chat),
                      Text("Start a Chat",
                        style: TextStyle(
                          fontSize: 16,
                        ),),
                    ]),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );  }
}
