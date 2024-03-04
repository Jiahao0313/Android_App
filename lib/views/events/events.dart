import 'package:babylon_app/models/event.dart';
import 'package:babylon_app/services/event/eventService.dart';
import 'package:flutter/material.dart';
import 'events-info.dart';
import 'create_event.dart';
// This file should contain the EventInfoScreen class.

// Define the Event class with all necessary information about an event, including the host and location.
// class Event {
//   final String title;
//   final String date;
//   final String time;
//   final String description;
//   final String host;
//   final String location;

//   Event(this.title, this.date, this.time, this.description, this.host, this.location);
// }

// Define the EventsScreen as a StatefulWidget to handle dynamic content like user events.
class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

// Define the corresponding State class for EventsScreen with TabController for tab navigation.
class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => CreateEventScreen()),
          // );
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
          // _buildEventList(upcomingEvents),
          // // Assuming _buildEventList is a method that returns a list of event cards.
          // _buildEventList([upcomingEvents[0]]), // Example for 'My Events' tab.
        ],
      ),
    );
  }

  // Method to build a list view of event cards.
  Widget _buildEventList(List<Event> events) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        return _buildEventCard(events[index]);
      },
    );
  }

  // Method to build a single event card widget.
  Widget _buildEventCard(Event event) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: Image.asset('assets/images/logoSquare.png', width: 100),
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