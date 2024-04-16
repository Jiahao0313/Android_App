import "package:flutter/material.dart";

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("News")),
      body: const Center(child: Column(children: [Text("News")])),
    );
  }
}
