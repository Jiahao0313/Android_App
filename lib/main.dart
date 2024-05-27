import "package:babylon_app/routes/custom_router.dart";
import "package:babylon_app/services/firebase_options.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/custom_theme.dart";
import "package:babylon_app/views/launch/splash.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> loadCurrentUserData() async {
    if (FirebaseAuth.instance.currentUser != null) {
      await UserService.setUpConnectedBabylonUser(
          userUID: FirebaseAuth.instance.currentUser!.uid);
    }
  }

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateRoute: CustomRouter.generatePreLoginRoutes,
      theme: CustomThemes.lightTheme,
      home: Splash(loadCurrentUserData: loadCurrentUserData),
    );
  }
}
