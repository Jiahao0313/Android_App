import "package:flutter/material.dart";

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MyAccount")),
      body: const Center(child: Column(children: [Text("MyAccount")])),
    );
  }
}
