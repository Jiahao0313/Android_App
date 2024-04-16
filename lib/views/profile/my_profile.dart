import "package:flutter/material.dart";

class MyProfile extends StatelessWidget {
  const MyProfile({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MyProfile")),
      body: const Center(child: Column(children: [Text("MyProfile")])),
    );
  }
}
