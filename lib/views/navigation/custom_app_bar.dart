import "package:babylon_app/models/connected_babylon_user.dart";
import "package:flutter/material.dart";

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isHome;
  const CustomAppBar({super.key, this.isHome = false});

  @override
  Widget build(final BuildContext context) {
    return AppBar(
      toolbarHeight: 90,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 90,
      leading: Container(
          padding: EdgeInsets.only(left: 10, bottom: 5),
          child: Image(
              image: AssetImage("assets/images/blackLogoSquare.png"),
              fit: BoxFit.cover)),
      actions: [
        Container(
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  )
                ],
              ),
            ))
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
