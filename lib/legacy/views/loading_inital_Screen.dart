import "package:babylon_app/legacy/views/main.dart";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:babylon_app/legacy/views/home.dart";

class LoadingScreen extends StatefulWidget {
  final Future<void> Function()? onHomeReady;

  const LoadingScreen({super.key, this.onHomeReady});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _waitForHome();
  }

  void _waitForHome() async {
    if (widget.onHomeReady != null) {
      await widget.onHomeReady!();
    }
    _checkUserAndNavigate();
  }

  void _checkUserAndNavigate() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (final context) => HomePage()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (final context) => LogoScreen()));
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDFDFD),
      body: Center(
        child: Image.asset("assets/images/loading.gif"),
      ),
    );
  }
}
