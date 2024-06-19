import "package:babylon_app/services/user/user_service.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:google_sign_in/google_sign_in.dart";

class AuthService {
  static Future<User?> registerUsingEmailPassword({
    required final String name,
    required final String email,
    required final String password,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
      UserService.setUpConnectedBabylonUser(
          userUID: user!
              .uid); // await BabylonUser.updateCurrentBabylonUserData(currentUserUID: user!.uid);
    } catch (e) {
      print(e);
      rethrow;
    }
    return user;
  }

  static Future<User?> signInUsingEmailPassword({
    required final String email,
    required final String password,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    try {
      final UserCredential userCredential =
        await auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      user = userCredential.user;
      UserService.setUpConnectedBabylonUser(
          userUID: user!
              .uid); // await BabylonUser.updateCurrentBabylonUserData(currentUserUID: user!.uid);
    } catch (e) {
      print(e);
      rethrow;
    }
    return user;
  }

  static Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    
    debugPrint("seeing google 1");
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    debugPrint("seeing google 2");

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    debugPrint("seeing google 3");

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    debugPrint("seeing google 4");
    final UserCredential signedIdUser =
        await FirebaseAuth.instance.signInWithCredential(credential);
    debugPrint("seeing google 5");

    await hasCurrentUserData();
    debugPrint("seeing google 6");
    UserService.setUpConnectedBabylonUser(
        userUID: signedIdUser.user!
            .uid); // await BabylonUser.updateCurrentBabylonUserData(currentUserUID: signedIdUser.user!.uid);
    debugPrint("seeing google 7");
    // Once signed in, return the UserCredential
    return signedIdUser;
  }

  static Future<void> hasCurrentUserData() async {
    try {
      final User currUser = FirebaseAuth.instance.currentUser!;
      final db = FirebaseFirestore.instance;
      final docUser = await db.collection("users").doc(currUser.uid).get();
      final userData = docUser.data();
      if (userData == null) {
        final userNewData = <String, dynamic>{
          "Country of Origin": "",
          "Date of Birth": DateTime.now().toLocal().toString(),
          "Email Address": currUser.email!,
          "Name": currUser.displayName!,
          "About": "",
          "creationTime": Timestamp.now()
        };
        userNewData["ImageUrl"] = currUser.photoURL!;
        await db.collection("users").doc(currUser.uid).set(userNewData);
      }
    } catch (e) {
      rethrow;
    }
  }
}
