import 'package:babylon_app/models/event.dart';
import 'package:babylon_app/services/event/eventService.dart';
import 'package:flutter/material.dart';
import 'events-info.dart';
import 'create_event.dart';

// Define the EventsScreen as a StatefulWidget to handle dynamic content like user events.
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

// Define the corresponding State class for EventsScreen with TabController for tab navigation.
class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Future<List<Event>> _events = EventService.getEvents();

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
  Widget build(BuildContext context){
    return Scaffold(
       // Custom drawer widget for navigation.
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var ui = await EventService.getEvents();
          print(ui);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
        // Alineación en la parte inferior izquierda

      ),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('Events'),
            SizedBox(
              height: 55,
              width: 55,
              child: Image.asset('assets/images/logowhite.png'), // Your logo asset.
            ),
          ],
        ),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'UPCOMING EVENTS'),
            Tab(text: 'MY EVENTS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventList(),
          // // Assuming _buildEventList is a method that returns a list of event cards.
          // _buildEventList([upcomingEvents[0]]), // Example for 'My Events' tab.
        ],
      ),
    );
  }

  // Method to build a list view of event cards.
  Widget _buildEventList() {
    return FutureBuilder<List<Event>>(
      future: _events, // a previously-obtained Future<String> or null
      builder:
          (BuildContext context, AsyncSnapshot<List<Event>> snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          print(1);
          print(snapshot.data);
          children = <Widget>[
            Padding(
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Text("Upcoming events",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...snapshot.data!.map((anEvent) => _buildEventCard(anEvent) )
          ];
        } else if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text('Error: ${snapshot.error}'),
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
                      child: CircularProgressIndicator(
                          color: Color(0xFF006400)),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Loading...'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 128),
                    child: Image.asset('assets/images/logoSquare.png',
                        height: 185, width: 185),
                  ),
                ],
              )
            ];
          }
        return ListView(
          children: children,
        );
      }
    );
  }

  // Method to build a single event card widget.
  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Image.network(event.PictureURL!),
        title: Text(event.Title!),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${event.Date!.day} at ${event.Date!.hour}'),
            Text(event.ShortDescription!, maxLines: 3, overflow: TextOverflow.ellipsis),
            Text('Host: ${event.Creator!.fullName}'), // Display the host of the event.
            Text('Location: ${event.Place}'), // Display the location of the event.
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () async{
            // When the info button is pressed, navigate to the EvonPentInfoScreen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventInfoScreen(event: event),
              ),
            );
          },
        ),
      ),
    );
  }
}