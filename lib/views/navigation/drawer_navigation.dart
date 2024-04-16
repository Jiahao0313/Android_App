import "package:babylon_app/routes/navigation_keys.dart";
import "package:flutter/material.dart";

class DrawerNavigation extends StatelessWidget {
  final Function updateSelectedMenuIndexCallback;
  const DrawerNavigation(
      {super.key, required this.updateSelectedMenuIndexCallback});

  @override
  Widget build(final BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              updateSelectedMenuIndexCallback(0);
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "home",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Community"),
            onTap: () {
              updateSelectedMenuIndexCallback(1);
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "community",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.newspaper),
            title: const Text("News"),
            onTap: () {
              updateSelectedMenuIndexCallback(2);
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "news",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text("Events"),
            onTap: () {
              updateSelectedMenuIndexCallback(3);
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "events",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.radio),
            title: const Text("Radio"),
            onTap: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "radio",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Offers"),
            onTap: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "offers",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("My account"),
            onTap: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "myAccount",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "home",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              layoutKey.currentState!.closeEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
