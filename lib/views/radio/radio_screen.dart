import "package:flutter/material.dart";

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RadioScreen")),
      body: const Center(child: Column(children: [Text("RadioScreen")])),
    );
  }
}
