import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/chat/chat_info.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/views/chat/create_new_chat.dart";
import "package:flutter/material.dart";
import "package:babylon_app/views/profile/other_profile.dart";
import "package:babylon_app/views/chat/chat_view.dart";
import "../chat/search_groupchat.dart";

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

  Future<List<BabylonUser?>> _requests = UserService.getConnectionsRequests();

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
    final currentUserUID = ConnectedBabylonUser().userUID;

    setState(() {
      searchResults =
          users.where((final user) => user.userUID != currentUserUID).toList();
    });
  }

  // Placeholder for search logic, currently updates searchResults based on query.
  void _search(final String query) async {
    if (query.isEmpty) {
      final allUsers = await UserService.getAllBabylonUsers();
      final currentUserUID = ConnectedBabylonUser().userUID;

      setState(() {
        searchResults = allUsers
            .where((final user) => user.userUID != currentUserUID)
            .toList();
      });
    } else {
      final searchResultsTemp = await UserService.searchBabylonUsers(query);
      final currentUserUID = ConnectedBabylonUser().userUID;

      setState(() {
        searchResults = searchResultsTemp
            .where((final user) => user.userUID != currentUserUID)
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
    return FutureBuilder(
        future: _requests,
        builder: (final BuildContext context,
            final AsyncSnapshot<List<BabylonUser?>> snapshot) {
          List<Widget> children = <Widget>[];
          Widget result;
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            children = <Widget>[
              ...snapshot.data!.map((final babylonUser) =>
                  _buildFriendRequest(context, babylonUser))
            ];
          }

          if (children.isNotEmpty) {
            result =
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("Friend Requests",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: children.length,
                    itemBuilder: (final context, final index) {
                      return children[index];
                    },
                  )),
            ]);
          } else {
            result = SizedBox.shrink();
          }

          return result;
        });
  }

  Widget _buildFriendRequest(
      final BuildContext context, final BabylonUser? request) {
    return Container(
      width:
          240, // Adjusted width for each friend request card to accommodate horizontal buttons.
      margin: EdgeInsets.only(
          left: 16.0, right: 16.0), // Add right margin to the last card.
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment
              .spaceAround, // Space elements evenly within the card.
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(request!.imagePath),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(request.fullName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
            ),
            // Horizontal buttons for "View Profile", "Accept", and "Decline" actions.
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Space buttons evenly.
              children: [
                IconButton(
                  icon: Icon(Icons.remove_red_eye_outlined, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (final context) =>
                              OtherProfile(babylonUser: request)),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    setState(() {
                      UserService.sendConnectionRequest(
                          requestUID: request.userUID);
                      UserService.setUpConnectedBabylonUser(
                          userUID: ConnectedBabylonUser().userUID);
                      _requests = UserService.getConnectionsRequests();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    // Placeholder for "Decline" action.
                    setState(() {
                      UserService.removeConnectionRequest(
                          requestUID: request.userUID);
                      UserService.setUpConnectedBabylonUser(userUID: ConnectedBabylonUser().userUID);
                      _requests = UserService.getConnectionsRequests();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
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
                                          builder: (final context) => OtherProfile(
                                              babylonUser:
                                                  BabylonUser())), // TODO(EnzoL): To fix by a real BabylonUser
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
              FutureBuilder<List<Chat>>(
                future: _myChats,
                builder: (BuildContext context, AsyncSnapshot<List<Chat>> snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    final List<Chat> filteredChats = isGroupChats
                        ? snapshot.data!.where((aChat) => aChat.adminUID != "" && aChat.adminUID != null).toList()
                        : snapshot.data!.where((aChat) => aChat.adminUID == null || aChat.adminUID == "").toList();
                    children = filteredChats.map((aChat) => _buildChat(chat: aChat)).toList();
                  } else if (snapshot.hasError) {
                    children = <Widget>[
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      Padding(padding: const EdgeInsets.only(top: 16), child: Text("Error: ${snapshot.error}")),
                    ];
                  } else {
                    children = <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(color: Color(0xFF006400)),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text("Loading..."),
                      ),
                    ];
                  }
                  return Column(children: children);
                },
              ),
            ],
          ),
          if (isGroupChats)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GroupChat()));
                },
                backgroundColor: Colors.blue,
                child: Icon(Icons.add),
              ),
            ),
          if (isGroupChats)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (final context) => SearchGroupChatView()));
                  },
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
      leading: InkWell(
        onTap: () => chat.adminUID == null || chat.adminUID == ""
            ? null
            : Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (final context) => ChatInfoView(chat: chat)),
              ),
        child: CircleAvatar(
          backgroundImage:
              NetworkImage(chat.iconPath!), // Placeholder for group snapshot.
          radius: 25, // Adjust the size of the CircleAvatar here.
        ),
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
              builder: (final context) => ChatView(
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
                              child: ImageLoader.loadProfilePicture(
                                  person.imagePath, 30),
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
                                  _buttonOption(
                                      "View Profile",
                                      Icons.visibility,
                                      context,
                                      person,
                                      pressedProfileButton),
                                  _buttonOption(
                                      person.friendRequests!.any((userUID) => userUID == ConnectedBabylonUser().userUID) ? "Pending" : "Send Request",
                                      Icons.person_add,
                                      context,
                                      person,
                                      pressedRequestButton),
                                  _buttonOption("Chat", Icons.chat, context,
                                      person, pressedChatButton),
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

  Widget _buttonOption(
      final String title,
      final IconData icon,
      final BuildContext context,
      final BabylonUser person,
      final void Function(BabylonUser) pressedFunction) {
    // Function to create a small, styled button for each action.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: ElevatedButton.icon(
        onPressed: () {
          pressedFunction(person);
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

  void pressedProfileButton(final BabylonUser babylonUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (final context) => OtherProfile(babylonUser: babylonUser)),
    );
  }

  void pressedRequestButton(final BabylonUser babylonUser) {
    UserService.sendConnectionRequest(requestUID: babylonUser.userUID);
    setState(() {
      searchResults.firstWhere((final search) => babylonUser.userUID == search.userUID).friendRequests!.add(ConnectedBabylonUser().userUID);
    });
  }

  void pressedChatButton(final BabylonUser babylonUser) {
    // TODO(EnzoL): need to access the personal conversation and if it does not exist -> chat request
  }

// Additional helper methods for building connection cards, handling accept/decline logic, etc., can be added here.
}
