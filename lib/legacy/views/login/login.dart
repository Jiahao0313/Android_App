import "package:babylon_app/services/auth/auth_service.dart";
import "package:babylon_app/views/home/home.dart";
import "package:babylon_app/views/layout.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:babylon_app/legacy/views/home.dart";

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"), // Title of the AppBar.
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0), // Padding around the form.
        child: LoginForm(), // The form widget for account creation.
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  String? _error;

  late final Map<String, TextEditingController> userInfoController = {
    "Email": _email,
    "Pasword": _password,
  };

  late final Map<String, String> userInfo = {
    "Email": _email.text,
    "Pasword": _password.text,
  };

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _error = "";
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _error = "";
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Logo
          Image.asset("assets/images/logoRectangle.png", height: 90, width: 365),
          SizedBox(height: 50), // Space after logo
          // Title
          Text(
            "Login into your account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red),
              )),
          SizedBox(height: 50), // Space after title
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Email",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 20), // Space between text fields
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: "Password",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            controller: _password,
            obscureText: true,
          ),
      
          SizedBox(height: 25), // Space after text fields
          // Login button that navigates to HomePage on press
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF006400),
              minimumSize: Size(365, 60), // Size of the button.
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(60.0), // Rounded edges for the button.
              ),
            ),
            onPressed: () async {
              try {
                final User? loginUser =
                    await AuthService.signInUsingEmailPassword(
                        email: _email.text, password: _password.text);
                if (loginUser is User) {
                  if (!context.mounted) return;
                //  Navigator.pushAndRemoveUntil(
                //     context,
                //     MaterialPageRoute(builder: (final context) => Layout()),
                //     (final route) => false,
                //   );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (final context) => HomePage()),
                    (final route) => false,
                  );
                }
              } catch (e) {
                setState(() {
                  _error = ("Please introduce your correct email and password");
                });
              }
            },
            child: const Text(
              "Login",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: "Lato",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
