import "package:flutter/material.dart";

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home"),
      ),
      body: Center(
          child: Column(children: [
        const Text("Home"),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("events");
            },
            child: const Text("Event"))
      ])),
    );
  }
}
