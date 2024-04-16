import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/legacy/views/home.dart";
import "package:babylon_app/legacy/views/profile/my_profile.dart";
import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart";

class PublicDrawer extends StatefulWidget {
  final Function(int) onItemSelected;

  const PublicDrawer({super.key, required this.onItemSelected});

  @override
  _PublicDrawerState createState() => _PublicDrawerState();
}

class _PublicDrawerState extends State<PublicDrawer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      // Drawer for side navigation
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeaderWithUserInfo(),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (final context) => HomePage())),
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Community"),
            onTap: () => widget.onItemSelected(1),
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text("News"),
            onTap: () => widget.onItemSelected(2),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text("Events"),
            onTap: () => widget.onItemSelected(3),
          ),
          ListTile(
            leading: const Icon(Icons.radio),
            title: const Text("Radio"),
            onTap: () => widget.onItemSelected(6),
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Offers"),
            onTap: () => widget.onItemSelected(5),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("My profile"),
            onTap: () {
              //Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (final context) => MyProfile()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Log out"),
            onTap: () async {
              //Navigator.pop(context);
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    "/logo/",
                    (final _) => false,
                  );
                }
              }
            },
          ),
          // Repeat ListTiles for other items...
        ],
      ),
    );
  }
}

class DrawerHeaderWithUserInfo extends StatefulWidget {
  const DrawerHeaderWithUserInfo({super.key});

  @override
  State<DrawerHeaderWithUserInfo> createState() =>
      _DrawerHeaderWithUserInfoState();
}

class _DrawerHeaderWithUserInfoState extends State<DrawerHeaderWithUserInfo> {
  late final BabylonUser? currentUser = ConnectedBabylonUser();
  @override
  void initState() {
    super.initState();
    // Initialize TabController with the number of tabs
  }

  @override
  void dispose() {
    // Dispose of the TabController when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final String fullName = currentUser?.fullName ?? "Unknown user";
    final String email = currentUser?.email ?? "email";
    final String? imgUrl = currentUser?.imagePath;
    final ImageProvider currentImg;

    if (imgUrl != null) {
      currentImg = NetworkImage(imgUrl);
    } else {
      currentImg = const AssetImage("assets/images/default_user_logo.png");
    }

    print(currentUser);
    // if (currentUser != null) {
    return SizedBox(
      height: 230,
      child: DrawerHeader(
        decoration: const BoxDecoration(
          color: Colors.green,
        ),
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            GestureDetector(
              child: CircleAvatar(
                radius: 52,
                backgroundImage: currentImg,
                backgroundColor: Colors
                    .green, //AssetImage("${currentUser?.photoURL}") //currentUser?.photoURL
              ),
              // Wrap the profile section with GestureDetector
              onTap: () {
                // Navigate to the MyProfile screen when the profile picture is tapped
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (final context) => MyProfile()));
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Text(fullName, style: const TextStyle(fontSize: 18)),
            const SizedBox(
              height: 5,
            ),
            Text(email, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

Future<bool> showLogOutDialog(final BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (final context) {
      return AlertDialog(
        title: const Text("Log out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text("Log out"),
          ),
        ],
      );
    },
  ).then((final value) => value ?? false);
}
