import 'package:flutter/material.dart';
import 'partners.dart';
import 'chats.dart';
import 'news.dart';
import 'forum.dart';
import 'events.dart';
import 'connections.dart';
import 'myprofile.dart';

// HomePage with a custom user profile section above the AppBar, a Drawer, and PageView for content navigation
class homePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homePage> with SingleTickerProviderStateMixin {
  // Controller for the tabs
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the number of tabs
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    // Dispose of the TabController when the widget is disposed
    _tabController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    // Function to handle drawer item tap events
    Navigator.pop(context); // Close the drawer
    _tabController.animateTo(index); // Change the tab to the selected index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        // Drawer for side navigation
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                "Drawer Header",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () => _selectTab(0),
            ),
            ListTile(
              leading: Icon(Icons.newspaper),
              title: Text('News'),
              onTap: () => _selectTab(1),
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Forum'),
              onTap: () => _selectTab(2),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Events'),
              onTap: () => _selectTab(3),
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chats'),
              onTap: () => _selectTab(4),
            ),
            ListTile(
              leading: Icon(Icons.connect_without_contact),
              title: Text('Connections'),
              onTap: () => _selectTab(5),
            ),
            ListTile(
              leading: Icon(Icons.business),
              title: Text('Partners'),
              onTap: () => _selectTab(6),
            ),
            // Repeat ListTiles for other items...
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
          child: GestureDetector( // Wrap the profile section with GestureDetector
          onTap: () {
        // Navigate to the MyProfile screen when the profile picture is tapped
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyProfile()));
        },
            // User profile section at the top of the body
            child: Container(
              color: Colors.grey.shade200,
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Text('PP', style: TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome,', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                        Text("Person's Name", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          SliverAppBar(
            // AppBar that becomes part of the scrollable content
            pinned: true, // Keeps the AppBar visible at the top
            floating: false,
            expandedHeight: 0.0, // No expanded height
            flexibleSpace: FlexibleSpaceBar(
              title: Text(''), // No title in the flexible space
            ),
            bottom: TabBar(
              controller: _tabController, // Setting the controller for the TabBar
              isScrollable: true, // Making the TabBar scrollable
              tabs: [
                Tab(icon: Icon(Icons.home), text: 'Home'),
                Tab(icon: Icon(Icons.newspaper), text: 'News'),
                Tab(icon: Icon(Icons.forum), text: 'Forum'),
                Tab(icon: Icon(Icons.event), text: 'Events'),
                Tab(icon: Icon(Icons.chat), text: 'Chats'),
                Tab(icon: Icon(Icons.connect_without_contact), text: 'Connections'),
                Tab(icon: Icon(Icons.business), text: 'Partners'),
              ],
            ),
          ),
          SliverFillRemaining(
            // Expanded to fill the remaining space for the TabBarView
            child: TabBarView(
              controller: _tabController, // Setting the controller for the TabBarView
              children: [
                HomeScreen(),
                NewsScreen(),
                ForumScreen(),
                EventsScreen(),
                ChatsScreen(),
                ConnectionsScreen(),
                PartnersScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Define other screens like HomeScreen, NewsScreen, etc., similar to the HomeScreen class
// Each screen will have its own layout and widgets

// Example HomeScreen class
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      // Using a ListView for scrollable content
      children: <Widget>[
        _buildUpcomingEventsSection(context),
        _buildForumsParticipationSection(context),
        _buildChatsSection(context),
        // Add more sections or widgets here if needed
      ],
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'UPCOMING EVENTS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Card(
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.grey,
                ),
                child: Icon(Icons.image, color: Colors.white), // Placeholder icon
              ),
              title: Text('EVENT NAME'),
              subtitle: Text('DATE\nTIME\nDescription...'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Info button action
                },
                child: Text('+ info'),
              ),
            ),
          ),
          // You can repeat the Card for more events or create a method to generate them based on data
        ],
      ),
    );
  }

  Widget _buildForumsParticipationSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'FORUMS PARTICIPATION',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildForumCard('FORUM TOPIC 1', '0 Replies', true),
              _buildForumCard('FORUM TOPIC 3', '1 Reply', true),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildForumCard('FORUM TOPIC 2', '3 Replies', true),
              _buildForumCard('FORUM TOPIC 4', '10 Replies', true),
            ],
          ),
          TextButton(
            onPressed: () {
              // Browse on forum action
            },
            child: Text('Browse on forum'),
          ),
        ],
      ),
    );
  }

  Widget _buildForumCard(String title, String subtitle, bool isOpen) {
    return Expanded( // Using Expanded to fill the available space in the Row
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card wrap its content
            children: <Widget>[
              Text(title),
              SizedBox(height: 4), // Add a small space between the text widgets
              Text(subtitle),
              SizedBox(height: 8), // Add some space before the button
              if (isOpen) // Only show the button if the forum is 'Open'
                ElevatedButton(
                  onPressed: () {
                    // Your button tap action here
                  },
                  child: Text('Open'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // Text Color
                    backgroundColor: Colors.blue,  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'CHATS',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('PERSON\'S NAME'),
            subtitle: Text('last message sent...'),
            trailing: TextButton(
              onPressed: () {
                // Open chat action
              },
              child: Text('Open'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text Color
                backgroundColor: Colors.blue, // Button Background Color
              ),
            ),
          ),
          // You can repeat the ListTile for more chats or create a method to generate them based on data
        ],
      ),
    );
  }
}
