import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class Splash extends StatefulWidget {
  final Future<void> Function() loadCurrentUserData;

  const Splash({super.key, required this.loadCurrentUserData});

  @override
  _Splash createState() => _Splash();
}

class _Splash extends State<Splash> {
  @override
  void initState() {
    super.initState();
    redirect();
  }

  void redirect() async {
    try {
      await widget.loadCurrentUserData();

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (!mounted) return;
      if (currentUser != null) {
        Navigator.of(context).pushReplacementNamed("layout");
      } else {
        Navigator.of(context).pushReplacementNamed("launch");
      }
    } catch (e) {
      rethrow;
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
