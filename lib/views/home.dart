import "dart:async";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/connection/connections.dart";
import "package:babylon_app/views/events/events.dart";
import "package:babylon_app/views/forum/forum.dart";
import "package:babylon_app/views/navigation_menu.dart";
import "package:babylon_app/views/news/news.dart";
import "package:babylon_app/views/offers/offers.dart";
import "package:babylon_app/views/radio/radio.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";

// HomePage with a custom user profile section above the AppBar, a Drawer, and PageView for content navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User? currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0; // Index for BottomNavigationBar
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Global key for the Scaffold

  // Define your screens here. For now, I"ll use placeholders.
  final List<Widget> _screens = [
    HomeScreen(), // Your main Home screen
    ConnectionsScreen(), // Placeholder for Community
    NewsScreen(), // Placeholder for News
    EventsScreen(),
    ForumScreen(),
    OffersScreen(),
    RadioScreen()
  ];

  @override
  void initState() {
    super.initState();
    UserService.setUpConnectedBabylonUser(
        userUID: currentUser!
            .uid); //BabylonUser.updateCurrentBabylonUserData(currentUserUID: currentUser!.uid);
    // Update the BabylonUser data with the current user
  }

  void _onItemTapped(final int index) {
    if (index == 4) {
      // If it"s the last index, open the Drawer
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (index < 5) {
      setState(() {
        _selectedIndex = index; // Update the selected item
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Use the global key here
      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Text("Home"),
              backgroundColor: Colors.green,
              iconTheme: IconThemeData(color: Colors.green),
              // Set your preferred shade of green here
              // Add other AppBar properties if needed
            )
          : null, // Only show AppBar when HomeScreen is displayed
      body: _screens[_selectedIndex], // Display the selected screen
      endDrawer: PublicDrawer(
        onItemSelected: (final index) {
          setState(() {
            _selectedIndex = index; // Actualiza el índice seleccionado
          });
          Navigator.of(context).pop(); // Cierra el drawer
        },
      ),
      // Your already defined Drawer
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors
            .green, // This sets the background color of the BottomNavigationBar
        selectedItemColor: Colors
            .white, // This sets the color of the selected item, for example, white
        unselectedItemColor:
            Colors.black, // Ensures that all items are displayed correctly
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: "News"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Events"),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: "More"), // Button to open the Drawer
        ],
        currentIndex: _selectedIndex > 4 ? 4 : _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Define other screens like HomeScreen, NewsScreen, etc., similar to the HomeScreen class
// Each screen will have its own layout and widgets

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

// Example HomeScreen class
class HomeScreenState extends State<HomeScreen> {
  BabylonUser user = ConnectedBabylonUser();

  Timer? timer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    timer = Timer.periodic(
        Duration(seconds: 3),
        (final Timer t) => setState(() {
              user = ConnectedBabylonUser();
            }));
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: const [Colors.green, Colors.white],
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: user.imagePath.startsWith("http")
                    ? NetworkImage(user.imagePath)
                    : AssetImage(user.imagePath)
                        as ImageProvider, // Maneja tanto las URL de la red como los assets locales.
                radius: 50.0,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 10),
              Text(
                "Welcome, ${user.fullName}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        _buildUpcomingEventsSection(context),
        _buildForumsParticipationSection(context),
        _buildChatsSection(context),
        // Agrega más secciones o widgets aquí si es necesario
      ],
    );
  }
}

Widget _buildUpcomingEventsSection(final BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "UPCOMING EVENTS",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Card(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey,
              ),
              child: const Icon(Icons.image,
                  color: Colors.white), // Placeholder icon
            ),
            title: const Text("EVENT NAME"),
            subtitle: const Text("DATE\nTIME\nDescription..."),
            trailing: ElevatedButton(
              onPressed: () {
                // Info button action
              },
              child: const Text("+ info"),
            ),
          ),
        ),
        // You can repeat the Card for more events or create a method to generate them based on data
      ],
    ),
  );
}

Widget _buildForumsParticipationSection(final BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "FORUMS PARTICIPATION",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildForumCard("FORUM TOPIC 1", "0 Replies", true),
            _buildForumCard("FORUM TOPIC 3", "1 Reply", true),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _buildForumCard("FORUM TOPIC 1", "0 Replies", true),
            _buildForumCard("FORUM TOPIC 3", "1 Reply", true),
          ],
        ),
        TextButton(
          onPressed: () {
            // Browse on forum action
          },
          child: const Text("Browse on forum"),
        ),
      ],
    ),
  );
}

Widget _buildForumCard(
    final String title, final String subtitle, final bool isOpen) {
  return Expanded(
    // Using Expanded to fill the available space in the Row
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card wrap its content
          children: <Widget>[
            Text(title),
            const SizedBox(
                height: 4), // Add a small space between the text widgets
            Text(subtitle),
            const SizedBox(height: 8), // Add some space before the button
            if (isOpen) // Only show the button if the forum is "Open"
              ElevatedButton(
                onPressed: () {
                  // Your button tap action here
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text Color
                  backgroundColor: Color(0xFF006400),
                ),
                child: const Text("Open"),
              ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildChatsSection(final BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "CHATS",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: const Text("PERSON\"S NAME"),
          subtitle: const Text("last message sent..."),
          trailing: TextButton(
            onPressed: () {
              // Open chat action
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, // Text Color
              backgroundColor: Color(0xFF006400), // Button Background Color
            ),
            child: const Text("Open"),
          ),
        ),
        // You can repeat the ListTile for more chats or create a method to generate them based on data
      ],
    ),
  );
}
