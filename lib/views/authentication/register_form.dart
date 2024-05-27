import "package:flutter/material.dart";

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("RegisterForm")),
      body: const Center(child: Column(children: [Text("RegisterForm")])),
    );
  }
}
