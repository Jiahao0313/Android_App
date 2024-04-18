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
        body: TabBarView(
          controller: _tabController,
          children: [_buildUpComingEventList(), _buildMyEventList()],
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
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text("Upcoming events",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
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
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16),
            child: Text("Upcoming events",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...loadedMyEvents.map((final anEvent) => _buildEventCard(anEvent)),
        ];
      } else if (loadedMyEvents.isEmpty) {
        children = <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 20.0), // Adjust the top margin here
              child: Text(
                "Your event list is empty! Time to plan something fun. 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
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

  Widget _buildEventCard(final Event event) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () async {
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (final context) => EventInfoScreen(event: event),
          //   ),
          // );
          setState(() {});
        },
        child: ListTile(
          leading: ImageLoader.loadEventPicture(event.pictureURL!),
          title: Text(event.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "${DateFormat("dd MMMM yyyy").format(event.date!)} at ${DateFormat("hh:mm aaa").format(event.date!)}"),
              Text(event.shortDescription!,
                  maxLines: 3, overflow: TextOverflow.ellipsis),
              Text(
                  "Host: ${event.creator!.fullName}"), // Display the host of the event.
              Text(
                  "Location: ${event.place}"), // Display the location of the event.
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              // When the info button is pressed, navigate to the EvonPentInfoScreen.
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (final context) => EventInfoScreen(event: event),
              //   ),
              // );
              setState(() {});
            },
          ),
        ),
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
