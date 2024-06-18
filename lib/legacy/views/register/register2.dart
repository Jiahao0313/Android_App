import "package:babylon_app/legacy/views/register/register3.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/legacy/views/home.dart";
import "package:babylon_app/views/layout.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "dart:io";
import "package:image_picker/image_picker.dart";

class RegisterPage2 extends StatefulWidget {
  const RegisterPage2({super.key});

  @override
  _RegisterPage2State createState() => _RegisterPage2State();
}

class _RegisterPage2State extends State<RegisterPage2> {
  File? _fileImage;
  //Image? smallImage;

  Future getImage() async {
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 400, imageQuality: 70);

    if (image != null) {
      setState(() {
        _fileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Profile"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
            horizontal: 20), // Adjust overall horizontal spacing
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              margin:
                  EdgeInsets.only(bottom: 25), // Adjust space below the logo
              child: Image.asset(
                "assets/images/logoRectangle.png",
                height: 90,
                width: 365,
              ),
            ),
            const Text(
              "Before we finish, let\"s set up your profile",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 125,
                backgroundColor: Color(0xFF006400),
                backgroundImage:
                    _fileImage != null ? FileImage(_fileImage!) : null,
                child: _fileImage == null ? Text("Photo") : null,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: getImage,
              child: const Text("Select file"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF006400),
                minimumSize: Size(365, 60), // Size of the button.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      60.0), // Rounded edges for the button.
                ),
              ),
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  if (_fileImage != null) {
                    await UserService.addPhoto(
                        user: currentUser, file: _fileImage!);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (final context) => Layout()),
                      // MaterialPageRoute(builder: (final context) => HomePage()),
                      (final route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please upload an image")));
                  }
                }
              },
              // onPressed: () async {
              //   final currentUser = FirebaseAuth.instance.currentUser;

              //   if (currentUser != null) {
              //     if (_fileImage != null) {
              //       await UserService.addPhoto(
              //           user: currentUser, file: _fileImage!);
              //     }
              //   else {
              //        ScaffoldMessenger.of(context).showSnackBar(
              //            SnackBar(content: Text("Please upload an image")));
              //      }
              //   }
              //   if (!mounted) return;

              //   // disable register"s second view
              //   // Navigator.push(
              //   //   context,
              //   //   MaterialPageRoute(builder: (context) => RegisterPage3()),
              //   // );

              //   if (!context.mounted) return;
              //   Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(builder: (final context) => Layout()),
              //     // MaterialPageRoute(builder: (final context) => HomePage()),
              //     (final route) => false,
              //   );
              // },
              child: const Text(
                "Finish",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Lato",
                ),
              ),
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(
            //       vertical:
            //           20), // Adjust space above and below the "Skip" button
            //   child: TextButton(
            //     onPressed: () {
            //       // disable 3rd register screen
            //       // Navigator.push(
            //       //   context,
            //       //   MaterialPageRoute(builder: (context) => RegisterPage3()),
            //       // );

            //       Navigator.pushAndRemoveUntil(
            //         context,
            //         MaterialPageRoute(builder: (final context) => Layout()),
            //         // MaterialPageRoute(builder: (final context) => HomePage()),
            //         (final route) => false,
            //       );
            //     },
            //     style: OutlinedButton.styleFrom(
            //       minimumSize: Size(365, 60), // Set the button size
            //       textStyle: const TextStyle(fontSize: 24, fontFamily: "Lato"),
            //       side: const BorderSide(width: 2.0, color: Colors.grey),
            //     ),
            //     child: const Text("Skip"),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
