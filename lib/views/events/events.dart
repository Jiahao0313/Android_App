import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/event/event_service.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:babylon_app/views/events/events_info.dart";
import "package:babylon_app/views/events/create_event.dart";

// Define the EventsScreen as a StatefulWidget to handle dynamic content like user events.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

// Define the corresponding State class for EventsScreen with TabController for tab navigation.
class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Future<List<Event>> _allEvents = EventService.getEvents();
  final Future<List<Event>> _myEvents =
      EventService.getListedEventsOfUser(uuid: ConnectedBabylonUser().userUID);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      // Custom drawer widget for navigation.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (final context) => CreateEventScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),

      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text("Events"),
            SizedBox(
              height: 55,
              width: 55,
              child: Image.asset(
                  "assets/images/logowhite.png"), // Your logo asset.
            ),
          ],
        ),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "UPCOMING EVENTS"), Tab(text: "MY EVENTS")],
          indicatorColor:
              Colors.white, // Color of the indicator of selected tab
          labelColor: Colors.white, // Color of the text
          unselectedLabelColor:
              Colors.black, // Color of the text of selected tabs
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAllEventList(), _buildMyEventList()],
      ),
    );
  }

  // Method to build a list view of event cards.
  Widget _buildAllEventList() {
    return FutureBuilder<List<Event>>(
        future: _allEvents, // a previously-obtained Future<String> or null
        builder: (final BuildContext context,
            final AsyncSnapshot<List<Event>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              children = <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text("Upcoming events",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...snapshot.data!
                    .map((final anEvent) => _buildEventCard(anEvent))
              ];
            } else {
              children = <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 20.0), // Adjust the top margin here
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
            }
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text("Error: ${snapshot.error}"),
              ),
            ];
          } else {
            children = <Widget>[
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child:
                          CircularProgressIndicator(color: Color(0xFF006400)),
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
          }
          return ListView(
            children: children,
          );
        });
  }

  Widget _buildMyEventList() {
    return FutureBuilder<List<Event>>(
        future: _myEvents, // a previously-obtained Future<String> or null
        builder: (final BuildContext context,
            final AsyncSnapshot<List<Event>> snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              children = <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text("Upcoming events",
                      textAlign: TextAlign.left,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                ...snapshot.data!
                    .map((final anEvent) => _buildEventCard(anEvent))
              ];
            } else {
              children = <Widget>[
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 20.0), // Adjust the top margin here
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
            }
          } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text("Error: ${snapshot.error}"),
              ),
            ];
          } else {
            children = <Widget>[
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child:
                          CircularProgressIndicator(color: Color(0xFF006400)),
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
          }
          return ListView(
            children: children,
          );
        });
  }

  // Method to build a single event card widget.
  Widget _buildEventCard(final Event event) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (final context) => EventInfoScreen(event: event),
            ),
          );
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
                  "Host: ${event.creator.fullName}"), // Display the host of the event.
              Text(
                  "Location: ${event.place}"), // Display the location of the event.
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              // When the info button is pressed, navigate to the EvonPentInfoScreen.
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (final context) => EventInfoScreen(event: event),
                ),
              );
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}
