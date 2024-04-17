import "package:babylon_app/routes/navigation_keys.dart";
import "package:flutter/material.dart";

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function updateSelectedMenuIndexCallback;
  const BottomNavigation(
      {super.key,
      required this.selectedIndex,
      required this.updateSelectedMenuIndexCallback});

  @override
  Widget build(final BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (final int index) {
        if (navigatorKey.currentState != null) {
          switch (index) {
            case 0:
              navigatorKey.currentState!.pushNamedAndRemoveUntil("home",
                  (final Route<dynamic> route) => route.settings.name == "home",
                  arguments: updateSelectedMenuIndexCallback);
              updateSelectedMenuIndexCallback(index);
              break;
            case 1:
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "community",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              updateSelectedMenuIndexCallback(index);
              break;
            case 2:
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "events",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              updateSelectedMenuIndexCallback(index);
              break;
            case 3:
              navigatorKey.currentState!.pushNamedAndRemoveUntil(
                  "news",
                  (final Route<dynamic> route) =>
                      route.settings.name == "home");
              updateSelectedMenuIndexCallback(index);
              break;
            case 4:
              layoutKey.currentState!.openEndDrawer();
              updateSelectedMenuIndexCallback(index);
              break;
          }
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_filled),
          label: "Home",
        ),
        NavigationDestination(
          icon: Icon(Icons.groups),
          label: "Community",
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month),
          label: "Events",
        ),
        NavigationDestination(
          icon: Icon(Icons.newspaper),
          label: "News",
        ),
        NavigationDestination(
          icon: Icon(Icons.menu),
          label: "More",
        ),
      ],
    );
  }
}
