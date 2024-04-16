import "package:flutter/material.dart";

class Forum extends StatelessWidget {
  const Forum({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Forum")),
      body: const Center(child: Column(children: [Text("Forum")])),
    );
  }
}
