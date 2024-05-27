import "package:flutter/material.dart";

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(final BuildContext context) {
    return Container(
        padding: EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF006400)),
            Container(
                padding: EdgeInsets.only(top: 8), child: Text("Loading...")),
          ],
        ));
  }
}
