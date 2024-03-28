import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/chat/create_new_groupchat.dart";
import "package:flutter/material.dart";
import "package:babylon_app/views/profile/other_profile.dart";
import "package:babylon_app/views/chat/group_chat.dart";

// Define ConnectionsScreen as a StatefulWidget to manage dynamic content.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

// Define the corresponding State class for ConnectionsScreen with a TabController for navigation.
class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController =
      TextEditingController(); // For search functionality.
  List<BabylonUser> searchResults = []; // Holds the search results.
  final Future<List<Chat>> _myChats =
      ChatService.getUserChats(userUID: ConnectedBabylonUser().userUID);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    final users = await UserService.getAllBabylonUsers();
    setState(() {
      // Convert BabylonUser instances to _Person instances, or directly use BabylonUser if you adjust the UI accordingly
      searchResults = users;
    });
  }

  // Placeholder for search logic, currently updates searchResults based on query.
  void _search(final String query) {
    if (query.isEmpty) {
      _fetchUsers();
    } else {
      setState(() {
        searchResults = searchResults
            .where((final person) =>
                person.fullName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text("Connections"),
            SizedBox(
              height: 55,
              width: 55,
              child: Image.asset("assets/images/logowhite.png"), // Logo asset.
            ),
          ],
        ),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "MY CONNECTIONS"),
            Tab(text: "DISCOVER PEOPLE"),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyConnectionsTab(), // "My Connections" tab with search and sections.
          _buildExploreWorldTab(), // "Explore The World" tab with search functionality.
        ],
      ),
    );
  }

  // Constructs "My Connections" tab with a search bar and sections for connections.
  Widget _buildMyConnectionsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildFriendRequestsWidget(), // Friend Requests section.
          _buildNewUsersWidget(), // New Users section.
          _buildChatsWidget(), // Chats section.
          _buildChatsWidget(isGroupChats: true), // Group Chats section.
        ],
      ),
    );
  }

  // Constructs the search bar widget.
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: "Search Connections",
          suffixIcon: Icon(Icons.search),
        ),
        onChanged:
            _search, // Invokes the search function with the current query.
      ),
    );
  }

  // Constructs the "Friend Requests" widget with a horizontal list of profiles.
  Widget _buildFriendRequestsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Friend Requests",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Container(
          height:
              200, // Fixed height for the horizontal list of friend request cards.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Example: Five friend requests.
            itemBuilder: (final context, final index) {
              // Each item is a profile card with image, name, and action buttons for friend requests.
              return Container(
                width:
                    240, // Adjusted width for each friend request card to accommodate horizontal buttons.
                margin: EdgeInsets.only(
                    left: 16.0,
                    right: index == 4
                        ? 16.0
                        : 0), // Add right margin to the last card.
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceAround, // Space elements evenly within the card.
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage("assets/images/default_user_logo.png"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text("_Person $index",
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      // Horizontal buttons for "View Profile", "Accept", and "Decline" actions.
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // Space buttons evenly.
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove_red_eye_outlined,
                                color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (final context) => OtherProfile()),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              // Placeholder for "Accept" action.
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              // Placeholder for "Decline" action.
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Constructs the "New Users" widget with a horizontal list of new user profiles.
  Widget _buildNewUsersWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("Welcome New Users!",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 200, // Fixed height for the horizontal list of profile cards.
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Example: Five new user profiles.
            itemBuilder: (final context, final index) {
              // Each item is a profile card with image, name, and action buttons for new users.
              return Container(
                width: 160, // Fixed width for each profile card.
                margin: EdgeInsets.only(
                    left: 16.0,
                    right: index == 4
                        ? 16.0
                        : 0), // Add right margin to the last card.
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  child: Wrap(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                  "assets/images/default_user_logo.png"),
                            ),
                            SizedBox(height: 10),
                            Text("New User $index",
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            ButtonBar(
                              alignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye_outlined,
                                      color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (final context) =>
                                              OtherProfile()),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.chat_bubble_outline,
                                      color: Colors.blue),
                                  onPressed: () {
                                    // Placeholder for "Chat" action.
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatsWidget({final bool isGroupChats = false}) {
    final String title = isGroupChats ? "Group chats" : "Chats";

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 3.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          FutureBuilder<List<Chat>>(
              future: _myChats, // a previously-obtained Future<String> or null
              builder: (final BuildContext context,
                  final AsyncSnapshot<List<Chat>> snapshot) {
                List<Widget> children;
                if (snapshot.hasData) {
                  final List<Chat> filteredChats = isGroupChats
                      ? snapshot.data!
                          .where((final aChat) =>
                              aChat.adminUID != "" && aChat.adminUID != null)
                          .toList()
                      : snapshot.data!
                          .where((final aChat) =>
                              aChat.adminUID == null || aChat.adminUID == "")
                          .toList();
                  children = <Widget>[
                    ...filteredChats
                        .map((final aChat) => _buildChat(chat: aChat))
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
                            child: CircularProgressIndicator(
                                color: Color(0xFF006400)),
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
                return Column(
                  children: children,
                );
              }),
          if (isGroupChats)
            Padding(
              padding: EdgeInsets.only(right: 16.0, bottom: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                // Floating action button for creating a new group chat, placed at the bottom right.
                child: FloatingActionButton(
                  onPressed: () async {
                    // BabylonUser? zozz = await UserService.getBabylonUser(
                    //     "GEWO8J4gCYYMYLwG2OmvXPxD8ah2");
                    // ChatService.createChat(otherUser: zozz);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (final context) => CreateNewGroupChat()),
                    );
                  },
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.add),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChat({required final Chat chat}) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      leading: CircleAvatar(
        backgroundImage:
            NetworkImage(chat.iconPath!), // Placeholder for group snapshot.
        radius: 25, // Adjust the size of the CircleAvatar here.
      ),
      title:
          Text(chat.chatName!, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
          chat.lastMessage == null || chat.lastMessage!.message == null
              ? ""
              : chat.lastMessage!.message!,
          maxLines: 3,
          overflow: TextOverflow.ellipsis),
      trailing: Icon(Icons.chat_bubble_outline, color: Colors.blue),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (final context) => GroupChatView(
                    chat: chat,
                  )),
        );
      },
    );
  }

  // Constructs "Explore The World" tab with a search bar and search results.
  Widget _buildExploreWorldTab() {
    // Check if a search query has been entered.
    final bool hasSearchQuery = searchController.text.isNotEmpty;

    return Column(
      children: [
        _buildSearchBar(), // Builds the search bar widget.
        Expanded(
          child: searchResults.isEmpty && hasSearchQuery
              ? _buildNoResultsFoundMessage() // Display this message if no results are found.
              : ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (final context, final index) {
                    final BabylonUser person = searchResults[index];
                    return Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      elevation: 3.0,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircleAvatar(
                                  radius: 30.0,
                                  backgroundImage: NetworkImage(person
                                      .imagePath) // Usa NetworkImage para cargar la imagen de la URL
                                  ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0, right: 10.0, bottom: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(person.fullName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.0)),
                                    SizedBox(height: 5),
                                    Text(person.about!,
                                        style: TextStyle(fontSize: 14.0)),
                                  ],
                                ),
                              ),
                            ),
                            VerticalDivider(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buttonOption("View Profile",
                                      Icons.visibility, context, person),
                                  _buttonOption("Send Request",
                                      Icons.person_add, context, person),
                                  _buttonOption(
                                      "Chat", Icons.chat, context, person),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNoResultsFoundMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[600]),
          SizedBox(
              height: 20), // Provides spacing between the icon and the text.
          Text(
            "No people found with that name.",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buttonOption(final String title, final IconData icon,
      final BuildContext context, final BabylonUser person) {
    // Function to create a small, styled button for each action.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: ElevatedButton.icon(
        onPressed: () {
          // Button functionality goes here, e.g., navigating to a profile page.
        },
        icon: Icon(icon, size: 18.0),
        label: Text(title, style: TextStyle(fontSize: 12.0)),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue.shade200, // Text color
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Rounded corners for a modern look
          ),
          textStyle: TextStyle(
            fontWeight: FontWeight.bold, // Bold text for clarity
          ),
        ),
      ),
    );
  }

// Additional helper methods for building connection cards, handling accept/decline logic, etc., can be added here.
}
