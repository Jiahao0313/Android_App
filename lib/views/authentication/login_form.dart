import "package:flutter/material.dart";

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LoginForm")),
      body: const Center(child: Column(children: [Text("LoginForm")])),
    );
  }
}
