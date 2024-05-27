import "dart:io";

import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:babylon_app/legacy/views/home.dart"; // Make sure this import is correct for your HomeScreen widget
import "package:babylon_app/legacy/views/connection/my_friends.dart";

class MyProfile extends StatefulWidget {
  const MyProfile({super.key});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool firstToggle = false;
  BabylonUser user = ConnectedBabylonUser();
  String formState = "unchanged";
  late final TextEditingController _fullname;
  late final TextEditingController _dateOfBirth;
  late final TextEditingController _country;
  late final TextEditingController _about;
  File? _fileImage;

  @override
  void initState() {
    _fullname = TextEditingController(text: ConnectedBabylonUser().fullName);
    _dateOfBirth =
        TextEditingController(text: ConnectedBabylonUser().dateOfBirth);
    _country =
        TextEditingController(text: ConnectedBabylonUser().originCountry);
    _about = TextEditingController(text: ConnectedBabylonUser().about);
    super.initState();
  }

  @override
  void dispose() {
    _fullname.dispose();
    _dateOfBirth.dispose();
    _country.dispose();
    _about.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Stack(
      children: [
        Scaffold(
            appBar: AppBar(
              // Replaced the menu icon with an arrow back icon
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  // Navigate back to HomeScreen when the arrow is pressed
                  formState == "unsaved"
                      ? _showBackPopup()
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (final context) => HomePage()));
                },
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildProfile(context),
                  const SizedBox(height: 12),
                  buildName(user),
                  const SizedBox(height: 12),
                  Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("Upgrade to Premium"),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade50,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          UserService.setUpConnectedBabylonUser(
                              userUID: ConnectedBabylonUser().userUID);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (final context) => MyFriends()),
                          );
                        },
                        child: Text("My Friends"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  infoField(
                      icon: Icons.person,
                      hintText: "example name",
                      labelText: "Full name",
                      controller: _fullname,
                      onClicked: () {}),
                  infoField(
                      icon: Icons.cake,
                      hintText: "Birth Date",
                      labelText: "Birth Date",
                      controller: _dateOfBirth,
                      onClicked: () {},
                      hasDatePicker: true),
                  infoField(
                      icon: Icons.public,
                      hintText: "Origin country",
                      labelText: "Origin country",
                      controller: _country,
                      onClicked: () {}),
                  infoField(
                      icon: Icons.chat,
                      hintText: "About",
                      labelText: "About",
                      controller: _about,
                      onClicked: () {}),
                  Center(
                    child: buildSaveButton(),
                  ),
                ],
              ),
            )),
        if (formState == "saving")
          const Opacity(
            opacity: 0.8,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (formState == "saving")
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget buildSaveButton() {
    String saveBtnText;
    switch (formState) {
      case "saving":
        saveBtnText = "Saving";
        break;
      case "saved":
        saveBtnText = "Saved";
      default:
        saveBtnText = "Save changes";
    }
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        onPressed: formState == "unsaved"
            ? () async {
                setState(() {
                  formState = "saving";
                });
                await UserService.updateUserInfo(uuid: user.userUID, newData: {
                  "name": _fullname.text,
                  "originCountry": _country.text,
                  "birthDate": _dateOfBirth.text,
                  "about": _about.text
                });
                UserService.setUpConnectedBabylonUser(
                    userUID: user
                        .userUID); // await BabylonUser.updateCurrentBabylonUserData(currentUserUID: user.userUID);
                if (_fileImage != null) {
                  UserService.addPhoto(
                      user: FirebaseAuth.instance.currentUser!,
                      file: _fileImage!);
                }
                await Future.delayed(Duration(seconds: 1));
                setState(() {
                  formState = "saved";
                  user = ConnectedBabylonUser();
                });
              }
            : null,
        child: Text(saveBtnText));
  }

  Widget buildProfile(final BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Center(
        child: Stack(
      children: [
        buildImage(),
        Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color, onClicked: getImage)),
      ],
    ));
  }

  Future<void> _showBackPopup() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (final BuildContext context) {
        return AlertDialog(
          title: const Text("You didn't save your changes"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    "Are you sure you want to leave without save your changes?"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Leave"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (final context) => HomePage()));
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  Future getImage() async {
    activateButton();
    final image = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 400, imageQuality: 70);

    if (image != null) {
      setState(() {
        _fileImage = File(image.path);
      });
    }
  }

  Widget buildImage() {
    ImageProvider image;
    if (_fileImage != null) {
      image = FileImage(_fileImage!);
    } else if (user.imagePath == "") {
      image = const AssetImage("assets/images/default_user_logo.png");
    } else {
      image = NetworkImage(user.imagePath);
    }
    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: getImage),
        ),
      ),
    );
  }

  Widget buildName(final BabylonUser user) => Column(
        children: [
          Text(
            user.fullName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  void activateButton() {
    setState(() {
      formState = "unsaved";
    });
  }

  Widget buildUpgradeButton() => ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: StadiumBorder(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      ),
      child: Text("Upgrade To PRO"),
      onPressed: () async => {activateButton()});

  Widget buildAbout(final BabylonUser user) => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "About",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              user.about!,
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
          ],
        ),
      );

  Widget infoField(
      {required final IconData icon,
      required final String hintText,
      required final String labelText,
      required final TextEditingController controller,
      required final Function onClicked,
      final bool hasDatePicker = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Center(
        child: Stack(children: [
          //Positioned(top: -5, right: 50, child: buildEditIcon(Colors.black)),
          Column(
            children: [
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      readOnly: hasDatePicker,
                      onTap: () async {
                        activateButton();
                        if (hasDatePicker) {
                          final DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1901),
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            setState(() {
                              _dateOfBirth.text =
                                  "${pickedDate.year}-${pickedDate.month < 10 ? "0${pickedDate.month}" : pickedDate.month}-${pickedDate.day}";
                            });
                          }
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(239, 237, 237, 0.5),
                        border: OutlineInputBorder(),
                        contentPadding: const EdgeInsets.all(10.0),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black38, width: 1.0),
                        ),
                        //label: Icon(Icons.settings),
                        hintText: hintText,
                        labelText: labelText,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          // Positioned(
          //     top: 0,
          //     right: 5,
          //     child: buildEditIcon(Theme.of(context).colorScheme.primary,
          //         onClicked: () {
          //       toggles[labelText] = true;
          //       toggles["Save"] = true;
          //       setState(() {
          //         this.toggles[labelText] = toggles[labelText]!;
          //         for (MapEntry<String, bool> toggle in toggles.entries) {
          //           if (toggle.key != labelText) {
          //             if (toggle.value) {
          //               if (toggle.key == "Name") {
          //                 if (_fullname.text ==
          //                     BabylonUser.currentBabylonUser.fullName) {
          //                   toggles[toggle.key] = false;
          //                 }
          //               }
          //             }
          //           }
          //         }
          //         //activateButton();
          //       });
          //     })),
        ]),
      ),
    );
  }

  Widget buildEditIcon1(final Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(Icons.edit, color: Colors.white, size: 12),
        ),
      );
  Widget buildEditIcon(final Color color, {required final onClicked}) =>
      ClipOval(
        child: Material(
          color: Colors.white,
          child: Ink.image(
            image: AssetImage("assets/images/iconEdit.png"),
            fit: BoxFit.cover,
            width: 30,
            height: 30,
            child: InkWell(onTap: onClicked),
          ),
        ),
      );

  Widget buildCircle({
    required final Widget child,
    required final double all,
    required final Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
  // Refactored profile section into a method for better readability

  // Method to build interests chips

  // Method to build languages chips
}

class NumbersWidget extends StatelessWidget {
  const NumbersWidget({super.key});

  @override
  Widget build(final BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButton(context, "admin"),
          buildDivider(),
          buildButton(context, "member"),
          //buildDivider(),
          //buildButton(context, "50", "Followers"),
        ],
      );

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(
            //color: Colors.black,
            ),
      );

  Widget buildButton(final BuildContext context, final String text) => SizedBox(
        width: 120,
        child: MaterialButton(
          shape: StadiumBorder(),
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 4),
          onPressed: () {},
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      );
}
