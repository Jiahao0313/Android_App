import "package:babylon_app/legacy/views/register/register1.dart";
import "package:babylon_app/services/auth/auth_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/authentication/login_form.dart";
import "package:babylon_app/views/layout.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class Launch extends StatelessWidget {
  const Launch({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 45),
              child: Image.asset("assets/images/logoSquare.png",
                  width: 185, height: 185),
            ),
            const Text(
              "Welcome to Babylon Radio!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: "Lato",
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 50, bottom: 50),
              child: const Text(
                "Celebrating cultures,\n" //\n breaks the line
                " promoting integration",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  fontFamily: "Lato",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(21),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                  // Navigator.of(context).push("login");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFF006400), // Background color of the button
                  minimumSize: const Size(350, 80), // Set the button size
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: "Lato",
                    color: Theme.of(context)
                        .colorScheme
                        .background, // Text color of the button
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 21, right: 21, bottom: 21),
              child: OutlinedButton(
                onPressed: () {
                  // Usa Navigator.push to navigate into RegisterScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateAccountPage()),
                  );
                  // Navigator.of(context).pushNamed("register");
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(350, 80), // Set the button size
                  textStyle: const TextStyle(fontSize: 24, fontFamily: "Lato"),
                  side: const BorderSide(
                      width: 2.0, color: Colors.grey), // Border width and color
                ),
                child: const Text("Register"),
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(horizontal: 42),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: Text("Continue with",
                            style: TextStyle(fontSize: 24, fontFamily: "Lato")),
                      ),
                      Flexible(
                          flex: 1,
                          child: _buildSocialButton(
                              "assets/images/google.png", // Replace with your asset
                              () async {
                            //        try {
                            // final UserCredential loginUser =
                            //     await AuthService.signInWithGoogle();
                            // UserService.setUpConnectedBabylonUser(
                            //     userUID: loginUser.user!.uid);
                            // if (!context.mounted) return;
                            // Navigator.pushAndRemoveUntil(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (final context) => HomePage()),
                            //   (final route) => false,
                            // );
                            try {
                              debugPrint("seeing 1");
                              final UserCredential loginUser = await AuthService.signInWithGoogle();
                              debugPrint("seeing 2");
                              await UserService.setUpConnectedBabylonUser(userUID: loginUser.user!.uid);
                              debugPrint("seeing 3");
                              if (!context.mounted) return;
                              debugPrint("seeing 4");
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        Layout()),
                                (final route) => false,
                              );
                              debugPrint("seeing 5");
                            } catch (e) {
                              debugPrint("google auth error" + e.toString());
                              print(e.toString());
                            }
                          }, 55, context)),
                      Flexible(
                          flex: 1,
                          child: _buildSocialButton(
                              "assets/images/facebook.png", // Replace with your asset
                              () async {
                            try {} catch (e) {
                              print(e.toString());
                            }
                          }, 55, context))
                    ])),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(final String iconPath, final VoidCallback onPressed,
      final double height, final BuildContext context) {
    return Container(
      height: height,
      child: FloatingActionButton(
        heroTag: UniqueKey(),

        onPressed: onPressed, // The social icon
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        child: Image.asset(iconPath), // Remove shadow
      ),
    );
  }
}
