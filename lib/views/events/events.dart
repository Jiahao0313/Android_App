import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";

class Events extends StatelessWidget {
  const Events({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Events"),
      body: Center(
          child: Column(children: [
        const Text("Events"),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("eventDetail");
            },
            child: const Text(
              "Event",
            ))
      ])),
    );
  }
}
