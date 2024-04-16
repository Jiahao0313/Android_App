import "package:flutter/material.dart";

class Community extends StatelessWidget {
  const Community({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Community")),
      body: const Center(child: Column(children: [Text("Community")])),
    );
  }
}
