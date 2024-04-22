import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/models/event.dart";
import "package:babylon_app/services/event/event_service.dart";
import "package:babylon_app/views/loading.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:intl/intl.dart";

class EventDetail extends StatefulWidget {
  final Event event;

  const EventDetail({super.key, required this.event});

  @override
  State<EventDetail> createState() => _EventDetail();
}

class _EventDetail extends State<EventDetail> {
  bool _hasDataLoaded = false;
  bool _isAttending = false;
  late Event eventState;

  @override
  void initState() {
    super.initState();
    eventState = widget.event;
    fetchData();
  }

  void fetchData() async {
    try {
      final List<BabylonUser> users =
          await EventService.getAttendees(event: eventState);
      setState(() {
        eventState.attendees = users;
        _isAttending = eventState.attendees!.any((final anAttendee) =>
            anAttendee.userUID == FirebaseAuth.instance.currentUser!.uid);
        _hasDataLoaded = true;
      });
    } catch (e) {
      rethrow;
    }
  }

  void reloadData() async {
    try {
      setState(() {
        _hasDataLoaded = false;
      });
      final reloadedEvent =
          await EventService.getEvent(eventUID: eventState.eventUID);
      if (reloadedEvent != null) {
        reloadedEvent.attendees =
            await EventService.getAttendees(event: reloadedEvent);
        setState(() {
          eventState = reloadedEvent;
          _hasDataLoaded = true;
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: eventState.title),
        body: _hasDataLoaded
            ? SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(context),
                        _buildInfo(context),
                        _buildAttendBtn(context),
                        _buildAttendees(context),
                        if (ConnectedBabylonUser().userUID ==
                            eventState.creatorUID)
                          _buildEditBtn(context)
                      ],
                    )))
            : Loading());
  }

  Widget _buildHero(final BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          margin: EdgeInsets.symmetric(vertical: 24),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child:
                  eventState.pictureURL != "" && eventState.pictureURL != null
                      ? Image.network(
                          eventState.pictureURL!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                        )
                      : Image.asset(
                          "assets/images/logoSquare.png",
                          fit: BoxFit.cover,
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                        ))),
      Text(
        eventState.title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (eventState.fullDescription != null)
        Container(
            margin: EdgeInsets.only(top: 12),
            child: Text(
              eventState.fullDescription!,
            ))
    ]);
  }

  Widget _buildInfo(final BuildContext context) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.calendar_month_outlined,
                    color: Color(0xFF018301),
                  ),
                ),
                Text(
                    "${DateFormat("dd MMMM yyyy").format(eventState.date!)} at ${DateFormat("KK:mm a").format(eventState.date!)}"),
              ],
            )),
        if (eventState.place != null)
          Container(
              margin: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.place_outlined,
                      color: Color(0xFF018301),
                    ),
                  ),
                  Text(eventState.place!),
                ],
              )),
        Container(
            margin: EdgeInsets.only(top: 0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.person_2_outlined,
                    color: Color(0xFF018301),
                  ),
                ),
                Text(
                  "Hosted by:",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                InkWell(
                  onTap: () => {
                    Navigator.pushNamed(context, "userProfile",
                        arguments: eventState.creator)
                  },
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(eventState.creator!.imagePath),
                          )),
                      Text(
                        eventState.creator!.fullName,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    ],
                  ),
                )
              ],
            )),
      ],
    );
  }

  Widget _buildAttendBtn(final BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: ElevatedButton(
            onPressed: () async {
              if (!_isAttending) {
                final bool added =
                    await EventService.addUserToEvent(event: eventState);
                if (added) {
                  setState(() {
                    _isAttending = true;
                    eventState.attendees!.add(ConnectedBabylonUser());
                  });
                }
              }
            },
            child: Text(_isAttending ? "ATTENDING" : "ATTEND")));
  }

  Widget _buildAttendees(final BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: InkWell(
          onTap: () => _showAllAttendeesBottomSheet(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "People Attending",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge, // Larger text for the section title.
              ),
              // Horizontally scrollable list of avatars with an overlap effect.
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                height: 70, // Adjusted height to accommodate the border.
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: eventState.attendees!
                      .length, // The total number of avatars to display.
                  itemBuilder: (final context, final index) {
                    // Wrapping each avatar with a Transform.translate to create an overlap effect.
                    return Transform.translate(
                      offset: Offset(-30.0 * index,
                          0), // Shifts each avatar to the left; adjust the multiplier as needed.
                      child: Container(
                        margin: EdgeInsets.only(
                            right: index != eventState.attendees!.length - 1
                                ? 20
                                : 0), // Adjust the right margin to control the overlap
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).colorScheme.background,
                              width: 3), // White border around the avatar
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              eventState.attendees![index].imagePath),
                          radius: 30, // The radius of avatars.
                        ),
                      ),
                    );
                  },
                ),
              ),
              OutlinedButton(
                  onPressed: () => _showAllAttendeesBottomSheet(context),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.group_outlined),
                    SizedBox(
                      width: 8,
                    ),
                    Text("See all (${eventState.attendees!.length})")
                  ]))
            ],
          ),
        ));
  }

  void _showAllAttendeesBottomSheet(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double bottomSheetHeight = screenSize.height * 0.75;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (final BuildContext context) {
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
                  Navigator.of(context)
                      .pop(); // Close the modal when the overlay is tapped
                },
              ),
            ),
            // Main bottom sheet content
            Container(
              margin:
                  EdgeInsets.only(top: screenSize.height - bottomSheetHeight),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: ListView.builder(
                itemCount: eventState.attendees!.length,
                itemBuilder: (final BuildContext context, final int index) {
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            eventState.attendees![index].imagePath),
                        radius: 20,
                      ),
                      title: Text(eventState.attendees![index].fullName,
                          style: TextStyle(fontSize: 16)),
                      onTap: () => {
                            Navigator.pushNamed(context, "userProfile",
                                arguments: eventState.attendees![index])
                          });
                },
              ),
            ),
            // Close button that "floats" above the bottom sheet and overlay
            Positioned(
              top: screenSize.height - bottomSheetHeight - 30,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.background),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditBtn(final BuildContext context) {
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 12, bottom: 12),
        child: OutlinedButton(
          onPressed: () async {
            await Navigator.pushNamed(context, "eventUpdateForm",
                arguments: eventState);
            reloadData();
          },
          style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.background),
              backgroundColor:
                  MaterialStatePropertyAll(Theme.of(context).primaryColor)),
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.edit),
            SizedBox(
              width: 8,
            ),
            Text("Edit my event")
          ]),
        ));
  }
}
