import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/event/event_service.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class Events extends StatefulWidget {
  const Events({super.key});
  @override
  State<Events> createState() => _Events();
}

class _Events extends State<Events> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Event> loadedUpcomingEvents = [];
  late List<Event> loadedMyEvents = [];
  final scrollController = ScrollController();
  late bool loadingEvents = false;
  late bool loadingMyEvents = false;
  late bool loadingMoreEvents = false;

  void getUpcomingEvents() async {
    try {
      setState(() {
        loadingEvents = true;
      });
      final List<Event> upcomingEvents = await EventService.getUpcomingEvents();
      setState(() {
        loadedUpcomingEvents.addAll(upcomingEvents);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        loadingEvents = false;
      });
    }
  }

  void getMyEvents() async {
    try {
      setState(() {
        loadingMyEvents = true;
      });
      final List<Event> myEvents = await EventService.getListedEventsOfUser(
          uuid: ConnectedBabylonUser().userUID);
      setState(() {
        loadedMyEvents.addAll(myEvents);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        loadingMyEvents = false;
      });
    }
  }

  void getMoreEventsStartByTheLastVisible(final Event lastVisibleEvent) async {
    try {
      setState(() {
        loadingMoreEvents = true;
      });
      final List<Event> moreEvents =
          await EventService.getMoreEvents(lastVisibleEvent);
      setState(() {
        loadedUpcomingEvents.addAll(moreEvents);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        loadingMoreEvents = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    getUpcomingEvents();
    getMyEvents();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_tabController.index == 0 && !loadingEvents && !loadingMoreEvents) {
          getMoreEventsStartByTheLastVisible(loadedUpcomingEvents.last);
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "Events"),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Color(0xFF018301),
              indicatorWeight: 10,
              tabs: const [
                Tab(text: "Upcoming events"),
                Tab(text: "My events")
              ],
              // Color of the text of selected tabs
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: [_buildUpComingEventList(), _buildMyEventList()],
            ))
          ],
        ));
  }

  Widget _buildUpComingEventList() {
    return Builder(builder: (final BuildContext context) {
      List<Widget> children;
      if (loadingEvents) {
        children = <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(color: Color(0xFF006400)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Loading..."),
              ),
              Padding(
                padding: EdgeInsets.only(top: 128),
                child: Image.asset("assets/images/logoSquare.png",
                    height: 185, width: 185),
              ),
            ],
          )
        ];
      } else if (loadedUpcomingEvents.isNotEmpty) {
        children = <Widget>[
          ...loadedUpcomingEvents
              .map((final anEvent) => _buildEventCard(anEvent)),
          _buildLoadingIndicator(loadingMoreEvents)
        ];
      } else if (loadedUpcomingEvents.isEmpty) {
        children = <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0), // Adjust the top margin here
              child: Text(
                "Event calendar is empty at the moment. Stay tuned for announcements! 📆",
              ),
            ),
          ),
        ];
      } else {
        children = <Widget>[
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text("Error"),
          ),
        ];
      }
      return ListView(
        controller: scrollController,
        children: children,
      );
    });
  }

  Widget _buildMyEventList() {
    return Builder(builder: (final BuildContext context) {
      List<Widget> children;
      if (loadingMyEvents) {
        children = <Widget>[
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(color: Color(0xFF006400)),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text("Loading..."),
              ),
              Padding(
                padding: EdgeInsets.only(top: 128),
                child: Image.asset("assets/images/logoSquare.png",
                    height: 185, width: 185),
              ),
            ],
          )
        ];
      } else if (loadedMyEvents.isNotEmpty) {
        children = <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
                onPressed: () => {
                      // TODO
                    },
                child: Text("ADD NEW EVENT")),
          ),
          ...loadedMyEvents.map((final anEvent) => _buildEventCard(anEvent)),
        ];
      } else if (loadedMyEvents.isEmpty) {
        children = <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
                onPressed: () => {}, child: Text("ADD NEW EVENT")),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0), // Adjust the top margin here
              child: Text(
                "Your event list is empty! Time to plan something fun. 🎉",
              ),
            ),
          ),
        ];
      } else {
        children = <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
                onPressed: () => {}, child: Text("ADD NEW EVENT")),
          ),
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text("Error"),
          ),
        ];
      }
      return ListView(
        controller: scrollController,
        children: children,
      );
    });
  }

  Widget _buildEventCard(final Event event) {
    return Card(
      surfaceTintColor: Colors.white,
      elevation: 10,
      shape:
          BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
      margin: const EdgeInsets.all(10),
      child: InkWell(
          onTap: () async {
            await Navigator.pushNamed(context, "eventDetail", arguments: event);
            setState(() {
              loadedMyEvents = [];
              loadedUpcomingEvents = [];
            });
            getUpcomingEvents();
            getMyEvents();
          },
          child: Container(
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: ImageLoader.loadEventPicture(event.pictureURL!),
                  ),
                  Expanded(
                      flex: 5,
                      child: Container(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 8),
                                child: Text(event.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_month_outlined,
                                      color: Color(0xFF018301),
                                    ),
                                  ),
                                  Text(DateFormat("dd/mm/yyyy | H:mm")
                                      .format(event.date!)),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.person_2_outlined,
                                      color: Color(0xFF018301),
                                    ),
                                  ),
                                  Text("Host: ${event.creator!.fullName}"),
                                ],
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.place_outlined,
                                      color: Color(0xFF018301),
                                    ),
                                  ),
                                  Text("Location: ${event.place}"),
                                ],
                              )
                            ],
                          ))),
                  Icon(
                    Icons.chevron_right_outlined,
                    color: Color(0xFF018301),
                  ),
                ],
              ))
          // ListTile(
          //   leading: ImageLoader.loadEventPicture(event.pictureURL!),
          //   title: Column(
          //     children: [],
          //   ),
          //   trailing: IconButton(
          //     icon: const Icon(Icons.chevron_right_sharp),
          //     onPressed: () async {
          //       // When the info button is pressed, navigate to the EvonPentInfoScreen.
          //       // await Navigator.push(
          //       //   context,
          //       //   MaterialPageRoute(
          //       //     builder: (final context) => EventInfoScreen(event: event),
          //       //   ),
          //       // );
          //       setState(() {});
          //     },
          //   ),
          // ),
          ),
    );
  }

  Widget _buildLoadingIndicator(final isLoading) {
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF006400)),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}
