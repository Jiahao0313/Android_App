import "package:flutter/material.dart";

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Events")),
      body: Center(
          child: Column(children: [
        const Text("Events"),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("eventDetail");
            },
            child: const Text("Event"))
      ])),
    );
  }
}
