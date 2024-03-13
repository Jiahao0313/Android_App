import 'package:babylon_app/models/babylonUser.dart';
import 'package:babylon_app/models/event.dart';
import 'package:babylon_app/services/event/eventService.dart';
import 'package:babylon_app/services/user/userService.dart';
import 'package:babylon_app/views/events/events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// EventInfoScreen displays detailed information about an event including the host and location.

class EventInfoScreen extends StatefulWidget {
  @override
  final Event event;
  const EventInfoScreen({Key? key, required this.event}) : super(key: key);
  EventInfoState createState() => EventInfoState(event);
}

class EventInfoState extends State<EventInfoScreen> {
  final Event event;
  EventInfoState(this.event);

  bool _isAttending = false;

  @override
  void initState() {
    super.initState();
    // Update the BabylonUser data with the current user

    _isAttending = event.Attendees.any((anAttendee) => anAttendee!.UserUID == FirebaseAuth.instance.currentUser!.uid);
  }
  
  // Event object passed through the constructor containing all event details.
  @override
  Widget build(BuildContext context) {
    // Use MediaQuery to get device width for responsive design.
    double screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    // Scaffold provides the AppBar at the top and a body for the content.
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            );
          },
        ),
        title: Text(
          event.Title!,
          style: TextStyle(
              fontSize: 24), // Increase font size for AppBar title for better visibility.
        ),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Container for the event image, taking full width of the screen.
            Container(
              width: screenWidth,
              child: Image.network(
                event.PictureURL!,
                height: 250, // Increase height for a more prominent image.
                fit: BoxFit.cover,
              ),
            ),
            // Padding for the content below the image.
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Event title with increased font size.
                  Text(
                    event.Title!,
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Event description with appropriate styling.
                  Text(
                    event.FullDescription!,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  // Row for the date with calendar icon.
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20),
                      SizedBox(width: 8),
                      // Text for the event date and time.
                      Text(
                        '${DateFormat('dd MMMM yyyy').format(event.Date!)} at ${DateFormat('hh:mm aaa').format(event.Date!)}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  // Row for the location with location icon.
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 8),
                      // Text for the event location.
                      Text(
                        event.Place!,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                      children: [
                        TextSpan(
                          text: 'Hosted by: ',
                        ),
                        WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(event.Creator!.imagePath),
                              radius: 20,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: event.Creator!.fullName,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),
                  // Attend button with larger text and padding.
                  ElevatedButton(
                    child: Text( _isAttending ? 'ATTENDING' : 'ATTEND', style: TextStyle(fontSize: 18)),
                    onPressed: () async{
                      if(!_isAttending){
                        bool added = await EventService.addUserToEvent(event);
                        if(added) 
                          {
                            setState(() {
                              _isAttending = true; 
                              event.Attendees.add(BabylonUser.currentBabylonUser);
                            });
                          }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAttending ? Color.fromARGB(255, 53, 136, 55) : Colors.green,
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                  ),
                  // Section for people attending the event.
                  _buildPeopleAttendingSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to build the 'People Attending' section.
  Widget _buildPeopleAttendingSection(BuildContext context) {
    // Replace with actual data
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'People Attending',
              style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 18), // Larger text for the section title.
            ),
          ),
          // Horizontally scrollable list of avatars with an overlap effect.
          Container(
            height: 70, // Adjusted height to accommodate the border.
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: event.Attendees.length, // The total number of avatars to display.
              itemBuilder: (context, index) {
                // Wrapping each avatar with a Transform.translate to create an overlap effect.
                return Transform.translate(
                  offset: Offset(-30.0 * index, 0), // Shifts each avatar to the left; adjust the multiplier as needed.
                  child: Container(
                    margin: EdgeInsets.only(right: index != event.Attendees.length - 1 ? 20 : 0), // Adjust the right margin to control the overlap
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3), // White border around the avatar
                    ),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(event.Attendees[index]!.imagePath),
                      radius: 30, // The radius of avatars.
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: OutlinedButton.icon(
              onPressed: () {
                // Opens a bottom sheet showing all attendees. The function to show the bottom sheet needs to be defined.
                _showAllAttendeesBottomSheet(context);
              },
              icon: Icon(Icons.person, size: 24), // Icon for the 'See all' button.
              label: Text(
                'See all (${event.Attendees.length})',
                style: TextStyle(fontSize: 16), // Text style for the 'See all' button.
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.green), // Border color to match the theme.
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to show a dialog with all attending users.
  void _showAllAttendeesBottomSheet(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double bottomSheetHeight = screenSize.height * 0.75;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Use a Stack to layer the elements correctly
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            // Semi-transparent overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: bottomSheetHeight,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(); // Close the modal when the overlay is tapped
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            // Main bottom sheet content
            Container(
              margin: EdgeInsets.only(top: screenSize.height - bottomSheetHeight),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: ListView.builder(
                itemCount: event.Attendees.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(event.Attendees[index]!.imagePath),
                      radius: 20,
                    ),
                    title: Text(event.Attendees[index]!.fullName, style: TextStyle(fontSize: 16)),
                    onTap: () {
                      // TODO: Implement navigation to attendee's profile
                    },
                  );
                },
              ),
            ),
            // Close button that 'floats' above the bottom sheet and overlay
            Positioned(
              top: screenSize.height - bottomSheetHeight - 30,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                child: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the bottom sheet
                },
              ),
            ),
          ],
        );
      },
    );
  }

}