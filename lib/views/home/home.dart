import "package:babylon_app/models/event.dart";
import "package:babylon_app/routes/navigation_keys.dart";
import "package:babylon_app/views/chats/chatting.dart";
import "package:babylon_app/views/community/community.dart";
import "package:babylon_app/views/events/events.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:babylon_app/views/news/news.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {
  final Function updateSelectedMenuIndexCallback;
  const Home({super.key, required this.updateSelectedMenuIndexCallback});

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: CustomAppBar(
          isHome: true,
          title: "",
        ),
        body: Column(
          children: [
            Expanded(
              child: Image.asset("assets/images/home-image.jpg",
                  fit: BoxFit.cover),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(255, 26, 25, 25),
                      spreadRadius: 1,
                      blurRadius: 15),
                ],
              ),
              height: MediaQuery.of(context).size.height * 0.3,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Column(children: [
                            SizedBox(
                              width: 100,
                              height: 0,
                            ),
                            Icon(
                              Icons.groups_2_outlined,
                              size: 40.0,
                            ),
                            Text("Community",
                                style: Theme.of(context).textTheme.bodyMedium)
                          ]),
                          onTap: () {
                            widget.updateSelectedMenuIndexCallback(1);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (final context) => Community()),
                                (final Route<dynamic> route) => true,
                            );
                          },
                        ),
                        InkWell(
                          child: Column(children: [
                            SizedBox(
                              width: 100,
                              height: 0,
                            ),
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 40.0,
                            ),
                            Text("Events",
                                style: Theme.of(context).textTheme.bodyMedium)
                          ]),
                          onTap: () {
                            widget.updateSelectedMenuIndexCallback(2);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (final context) => Events()),
                                (final Route<dynamic> route) => true,
                            );
                          },
                        ),
                        InkWell(
                            child: Column(children: [
                              SizedBox(
                                width: 100,
                                height: 0,
                              ),
                              Icon(
                                Icons.chat_outlined,
                                size: 40.0,
                              ),
                              Text(
                                "Chats",
                                style: Theme.of(context).textTheme.bodyMedium,
                              )
                            ]),
                            onTap: () {
                              widget.updateSelectedMenuIndexCallback(4);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (final context) => Chatting()),
                                (final Route<dynamic> route) => true,
                            );
                          },
                          ),
                      ]),
                  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          child: Column(children: [
                            SizedBox(
                              width: 100,
                              height: 0,
                            ),
                            Icon(
                              Icons.store_outlined,
                              size: 40.0,
                            ),
                            Text("Market",
                                style: Theme.of(context).textTheme.bodyMedium)
                          ]),
                          onTap: () {
                            widget.updateSelectedMenuIndexCallback(4);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                "home",
                                (final Route<dynamic> route) =>
                                    route.settings.name == "home");
                          },
                        ),
                        InkWell(
                          child: Column(children: [
                            SizedBox(
                              width: 100,
                              height: 0,
                            ),
                            Icon(
                              Icons.newspaper_outlined,
                              size: 40.0,
                            ),
                            Text("News",
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                          onTap: () {
                            widget.updateSelectedMenuIndexCallback(3);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (final context) => News()),
                                (final Route<dynamic> route) => true,
                            );
                          },
                        ),
                        InkWell(
                            child: Column(children: [
                              SizedBox(
                                width: 100,
                                height: 0,
                              ),
                              Icon(
                                Icons.control_point,
                                size: 40.0,
                              ),
                              Text("More",
                                  style: Theme.of(context).textTheme.bodyMedium)
                            ]),
                            onTap: () {
                              layoutKey.currentState!.openEndDrawer();
                            }),
                      ]),
                ],
              ),
            )
          ],
        ));
  }
}
