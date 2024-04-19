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

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      final List<BabylonUser> users =
          await EventService.getAttendees(event: widget.event);
      setState(() {
        widget.event.attendees = users;
        _isAttending = widget.event.attendees!.any((final anAttendee) =>
            anAttendee.userUID == FirebaseAuth.instance.currentUser!.uid);
        _hasDataLoaded = true;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: widget.event.title),
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
                            widget.event.creatorUID)
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
              child: widget.event.pictureURL != "" &&
                      widget.event.pictureURL != null
                  ? Image.network(
                      widget.event.pictureURL!,
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
        widget.event.title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      if (widget.event.fullDescription != null)
        Container(
            margin: EdgeInsets.only(top: 12),
            child: Text(
              widget.event.fullDescription!,
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
                    "${DateFormat("dd MMMM yyyy").format(widget.event.date!)} at ${DateFormat("KK:mm a").format(widget.event.date!)}"),
              ],
            )),
        if (widget.event.place != null)
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
                  Text(widget.event.place!),
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
                        arguments: widget.event.creator)
                  },
                  child: Row(
                    children: [
                      Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(widget.event.creator!.imagePath),
                          )),
                      Text(
                        widget.event.creator!.fullName,
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
                    await EventService.addUserToEvent(event: widget.event);
                if (added) {
                  setState(() {
                    _isAttending = true;
                    widget.event.attendees!.add(ConnectedBabylonUser());
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
                  itemCount: widget.event.attendees!
                      .length, // The total number of avatars to display.
                  itemBuilder: (final context, final index) {
                    // Wrapping each avatar with a Transform.translate to create an overlap effect.
                    return Transform.translate(
                      offset: Offset(-30.0 * index,
                          0), // Shifts each avatar to the left; adjust the multiplier as needed.
                      child: Container(
                        margin: EdgeInsets.only(
                            right: index != widget.event.attendees!.length - 1
                                ? 20
                                : 0), // Adjust the right margin to control the overlap
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white,
                              width: 3), // White border around the avatar
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.event.attendees![index].imagePath),
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
                    Text("See all (${widget.event.attendees!.length})")
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
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: ListView.builder(
                itemCount: widget.event.attendees!.length,
                itemBuilder: (final BuildContext context, final int index) {
                  return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                            widget.event.attendees![index].imagePath),
                        radius: 20,
                      ),
                      title: Text(widget.event.attendees![index].fullName,
                          style: TextStyle(fontSize: 16)),
                      onTap: () => {
                            Navigator.pushNamed(context, "userProfile",
                                arguments: widget.event.attendees![index])
                          });
                },
              ),
            ),
            // Close button that "floats" above the bottom sheet and overlay
            Positioned(
              top: screenSize.height - bottomSheetHeight - 30,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                child: Icon(Icons.close, color: Colors.white),
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
          onPressed: () => {
            // TODO
          },
          style: ButtonStyle(
              foregroundColor: MaterialStatePropertyAll(Colors.white),
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
