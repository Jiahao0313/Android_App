import "package:babylon_app/models/connected_babylon_user.dart";
import "package:flutter/material.dart";

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  const CustomAppBar({super.key, this.isHome = false});

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      backgroundColor: isHome ? Colors.transparent : Colors.white,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.white,
      elevation: isHome ? null : 5,
      toolbarHeight: isHome ? 90 : 120,
      leadingWidth: isHome ? 90 : 200,
      leading: isHome
          ? Container(
              padding: EdgeInsets.only(left: 10, bottom: 5),
              child: Image(
                  image: AssetImage("assets/images/blackLogoSquare.png"),
                  fit: BoxFit.cover))
          : Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 30),
              child: Text(
                "Events",
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
                        style: Theme.of(context).textTheme.displaySmall,
                      )
                    ],
                  ),
                ))
            : Container(
                padding: EdgeInsets.only(right: 30),
                child: Image(
                    width: 80,
                    image: AssetImage("assets/images/logoSquare.png"),
                    fit: BoxFit.cover))
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(isHome ? 90 : 120);
}
