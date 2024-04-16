import "package:flutter/material.dart";

class Launch extends StatelessWidget {
  const Launch({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Launch")),
      body: Center(
          child: Column(children: [
        const Text("Launch"),
        ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                "layout",
              );
            },
            child: const Text("HOME"))
      ])),
    );
  }
}
