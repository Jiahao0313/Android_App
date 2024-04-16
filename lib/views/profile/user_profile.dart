import "package:flutter/material.dart";

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("UserProfile")),
      body: const Center(child: Column(children: [Text("UserProfile")])),
    );
  }
}
