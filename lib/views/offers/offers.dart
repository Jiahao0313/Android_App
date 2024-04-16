import "package:flutter/material.dart";

class Offers extends StatelessWidget {
  const Offers({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Offers")),
      body: const Center(child: Column(children: [Text("Offers")])),
    );
  }
}
