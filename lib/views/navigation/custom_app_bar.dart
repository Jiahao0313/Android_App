import "package:babylon_app/legacy/views/profile/my_profile.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/views/profile/my_account.dart";
import "package:flutter/material.dart";

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  final String title;
  const CustomAppBar({super.key, required this.title, this.isHome = false});

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      backgroundColor: isHome
          ? Colors.transparent
          : Theme.of(context).colorScheme.background,
      shadowColor: Theme.of(context).colorScheme.onBackground,
      surfaceTintColor: Theme.of(context).colorScheme.background,
      elevation: isHome ? null : 5,
      toolbarHeight: 90,
      title: isHome
          ? Container(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Image(
                  width: 80,
                  image: AssetImage("assets/images/blackLogoSquare.png"),
                  fit: BoxFit.cover))
          : Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              )),
      actions: [
        isHome
            ? Container(
                padding: EdgeInsets.only(right: 20),
                child: InkWell(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(ConnectedBabylonUser().imagePath),
                        minRadius: 30,
                      ),
                      Text(
                        "My profile",
                        style: Theme.of(context).textTheme.titleLarge,
                      )
                    ],
                  ),
                  onTap: (){
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (final context) => MyAccount()),
                        (final route) => true,
                    );
                  },
                ))
            : Container(
                padding: EdgeInsets.only(right: 30),
                child: Image(
                    width: 60,
                    image: AssetImage("assets/images/logoSquare.png"),
                    fit: BoxFit.cover))
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(90);
}
