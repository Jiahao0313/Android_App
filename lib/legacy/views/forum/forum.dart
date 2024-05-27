import "package:flutter/material.dart";

// Define the Discussion class to hold information about each forum discussion.
class Discussion {
  final String title;
  final String author;
  final String excerpt;
  final DateTime timestamp;

  Discussion(this.title, this.author, this.excerpt, this.timestamp);
}

// Define the ForumScreen as a StatefulWidget to handle dynamic content.
class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

// Define the corresponding State class for ForumScreen.
class _ForumScreenState extends State<ForumScreen> {
  // A list of discussions for the forum. In a real app, this would be fetched from a backend.
  List<Discussion> discussions = [
    // Sample discussions. Replace with real data.
    Discussion(
        "How to implement a ListView in Flutter",
        "Alice",
        "I am trying to create a list view in Flutter...",
        DateTime.now().subtract(Duration(minutes: 10))),
    Discussion(
        "State Management Solutions",
        "Bob",
        "What are the best state management solutions for large apps in Flutter?",
        DateTime.now().subtract(Duration(hours: 1))),
    // Add more discussions here...
  ];

  // The TextEditingController for the search functionality.
  TextEditingController searchController = TextEditingController();

  // This method is called when the search text changes.
  void _searchDiscussions(final String query) {
    // TODO(EnzoL): Implement search functionality to filter the discussions list.
  }

  @override
  void initState() {
    super.initState();
    // You might want to initialize your data here if you"re fetching it from a backend.
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        actions: [
          IconButton(
            icon: Icon(Icons.create),
            onPressed: () {
              // TODO(EnzoL): Implement navigation to the "Create Discussion" screen.
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search discussions",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: _searchDiscussions,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: discussions.length,
              itemBuilder: (final context, final index) {
                return _buildDiscussionCard(discussions[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // TODO(EnzoL): Implement the "Create New Discussion" action.
        },
      ),
    );
  }

  // Build a card for each discussion.
  Widget _buildDiscussionCard(final Discussion discussion) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(discussion.title),
        subtitle: Text(
          discussion.excerpt,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing:
            Text("${discussion.timestamp.hour}:${discussion.timestamp.minute}"),
        onTap: () {
          // TODO(EnzoL): Implement navigation to the "Discussion Details" screen.
        },
      ),
    );
  }
}
