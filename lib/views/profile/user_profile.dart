import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";

class UserProfile extends StatefulWidget {
  final BabylonUser user;
  const UserProfile({super.key, required this.user});

  @override
  State<UserProfile> createState() => _UserProfile();
}

class _UserProfile extends State<UserProfile> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.user.fullName),
      body: const Center(child: Column(children: [Text("UserProfile")])),
    );
  }
}

// Display the user information in a pop up after searching
// class UserProfileCard 
