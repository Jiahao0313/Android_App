import "package:babylon_app/legacy/views/radio/radio.dart";
import "package:babylon_app/routes/navigation_keys.dart";
import "package:babylon_app/views/community/community.dart";
import "package:babylon_app/views/events/events.dart";
import "package:babylon_app/views/launch/launch.dart";
import "package:babylon_app/views/news/news.dart";
import "package:babylon_app/views/offers/offers.dart";
import "package:babylon_app/views/profile/my_account.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

class DrawerNavigation extends StatelessWidget {
  final Function updateSelectedMenuIndexCallback;
  const DrawerNavigation(
      {super.key, required this.updateSelectedMenuIndexCallback});

  Future<bool> showLogOutDialog(final BuildContext context) async {
    return await showDialog<bool>(
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
        ) ??
        false;
  }

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.home_filled),
            title: const Text("Home"),
            onTap: () {
              updateSelectedMenuIndexCallback(0);
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "home",
                  arguments: updateSelectedMenuIndexCallback,
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.groups_2_outlined),
            title: const Text("Community"),
            onTap: () {
              updateSelectedMenuIndexCallback(1);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (final context) => Community()),
                  (final Route<dynamic> route) => true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.newspaper_outlined),
            title: const Text("News"),
            onTap: () {
              updateSelectedMenuIndexCallback(3);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (final context) => News()),
                (final Route<dynamic> route) => true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text("Events"),
            onTap: () {
              updateSelectedMenuIndexCallback(2);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (final context) => Events()),
                (final Route<dynamic> route) => true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.radio_outlined),
            title: const Text("Radio"),
            onTap: () {
              updateSelectedMenuIndexCallback(4);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (final context) => RadioScreen()),
                (final Route<dynamic> route) => true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business_outlined),
            title: const Text("Offers"),
            onTap: () {
              updateSelectedMenuIndexCallback(4);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (final context) => Offers()),
                (final Route<dynamic> route) => true,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_2_outlined),
            title: const Text("My account"),
            onTap: () {
              updateSelectedMenuIndexCallback(4);
              layoutKey.currentState!.closeEndDrawer();
              navigatorKey.currentState!.pushAndRemoveUntil(
                MaterialPageRoute(builder: (final context) => MyAccount()),
                (final Route<dynamic> route) => true,
              );              
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text("Logout"),
            onTap: () async {
              updateSelectedMenuIndexCallback(4);
              final shouldLogout = await showLogOutDialog(context);
              if (shouldLogout) {

                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;
                // Navigator.of(context).pushNamedAndRemoveUntil(
                //     "launch",
                //     (final Route<dynamic> route) =>
                //         route.settings.name == "launch");
                if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => Launch()),
                    (Route<dynamic> route) => false,
                  );  
              }
            },
          ),
        ],
      ),
    );
  }
}
