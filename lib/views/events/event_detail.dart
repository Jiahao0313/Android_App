import "package:flutter/material.dart";

class EventDetail extends StatelessWidget {
  const EventDetail({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("EventDetail")),
      body: Center(
          child: Column(children: [
        const Text("EventDetail"),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("events");
            },
            child: const Text("Event"))
      ])),
    );
  }
}
