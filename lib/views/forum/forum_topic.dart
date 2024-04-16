import "package:flutter/material.dart";

class ForumTopic extends StatelessWidget {
  const ForumTopic({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ForumTopic")),
      body: const Center(child: Column(children: [Text("ForumTopic")])),
    );
  }
}
