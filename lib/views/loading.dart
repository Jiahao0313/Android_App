import "package:flutter/material.dart";

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: const [
            CircularProgressIndicator(color: Color(0xFF006400)),
            Text("Loading..."),
          ],
        ));
  }
}
