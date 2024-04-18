import "package:babylon_app/routes/custom_router.dart";
import "package:babylon_app/routes/navigation_keys.dart";
import "package:babylon_app/views/home.dart";
import "package:babylon_app/views/navigation/bottom_navigation.dart";
import "package:babylon_app/views/navigation/drawer_navigation.dart";
import "package:flutter/material.dart";

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _Layout();
}

class _Layout extends State<Layout> {
  int selectedMenuIndex = 0;

  void updateSelectedMenuIndex(final int newIndex) {
    setState(() => selectedMenuIndex = newIndex);
  }

  @override
  void initState() {
    super.initState();
  }

  // the layout is used to show bottom nav bar and hold end drawer
  // it contains navigation related states and callbacks
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        key: layoutKey,
        // if in home screen dont show bottomNavBar
        bottomNavigationBar: selectedMenuIndex == 0
            ? null
            : BottomNavigation(
                selectedIndex: selectedMenuIndex,
                updateSelectedMenuIndexCallback: updateSelectedMenuIndex),
        endDrawer: DrawerNavigation(
            updateSelectedMenuIndexCallback: updateSelectedMenuIndex),
        body: Navigator(
            key: navigatorKey,
            onGenerateInitialRoutes: ((final navigator, final initialRoute) => [
                  MaterialPageRoute(
                      builder: (final _) => Home(
                          updateSelectedMenuIndexCallback:
                              updateSelectedMenuIndex))
                ]),
            onGenerateRoute: CustomRouter.generatePostLoginRoutes));
  }
}
