import "package:flutter/material.dart";

class Chatting extends StatelessWidget {
  const Chatting({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chatting")),
      body: const Center(child: Column(children: [Text("Chatting")])),
    );
  }
}
