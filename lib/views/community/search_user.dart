import "package:babylon_app/legacy/views/chat/chat_view.dart";
import "package:babylon_app/legacy/views/profile/other_profile.dart";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/views/community/community.dart";
import "package:babylon_app/views/loading.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:babylon_app/views/profile/user_profile.dart";
import "package:flutter/animation.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'dart:ui';
import "package:flutter/widgets.dart";


class Search extends StatefulWidget {
  const Search({super.key});
  @override
  State<Search> createState() => _Search();
}

class _Search extends State<Search> with SingleTickerProviderStateMixin {
  final scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  late List<BabylonUser> myFriends = [];
  late List<BabylonUser> newUsers = [];
  late List<BabylonUser> searchResults = [];
  late bool isMyConnectionsDataLoading;
  late bool _isSearchedUsersShowing = false;


  @override
  void initState() {
    super.initState();
    fetchMyFriends();
  }

  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void fetchMyFriends() async {
    try {
      setState(() {
        isMyConnectionsDataLoading = true;
      });
      final List<BabylonUser> friends = await UserService.getConnections();
      setState(() {
        myFriends.addAll(friends);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isMyConnectionsDataLoading = false;
      });
    } 
  }

  // Buttons for check users details
  void pressedProfileButton(final BuildContext context, final BabylonUser babylonUser) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return Dialog(
          child: Column(mainAxisSize: MainAxisSize.min,children: [
              UserProfileDialog(user: babylonUser),
                          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  UserService.sendConnectionRequest(
                    requestUID: babylonUser.userUID,
                  );
                  UserService.setUpConnectedBabylonUser(
                    userUID: ConnectedBabylonUser().userUID,
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:[
                    Icon(Icons.person_add_outlined, 
                    color: Theme.of(context).colorScheme.primary),
                    Text("Add Friend",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary
                    ),),
                  ]),
              ),
              
              ElevatedButton(
                onPressed: () async {
                  final Chat? newChat = await ChatService.createChat(
                    otherUser: babylonUser,
                  );
                  if (newChat != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (final context) => ChatView(
                          chat: newChat,
                        ),
                      ),
                    );
                  }
                },
                style: ButtonStyle(
                  iconColor: MaterialStateProperty.all(Colors.orange),
                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  shadowColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const <Widget>[
                    Icon(Icons.chat_outlined),
                    Text("Start Chat",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange
                      ),),
                  ]
                ),
              ),
            ],
          ),
          SizedBox(height: 30,)
          ],),
        ); 
      },
    );
  }


  void pressedRequestButton(final BuildContext context, final BabylonUser babylonUser) {
    UserService.sendConnectionRequest(requestUID: babylonUser.userUID);
    setState(() {
      searchResults
        .firstWhere((final search) => babylonUser.userUID == search.userUID)
        .connectionRequestsUIDs!
        .add(ConnectedBabylonUser().userUID);
    });
  }

  void pressedChatButton(final BuildContext context, final BabylonUser babylonUser) async {
    final Chat? newChat = await ChatService.createChat(otherUser: babylonUser);
    if (newChat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (final context) => ChatView(
                  chat: newChat,
            )
        ),
      );
    }
  }


  Widget _buildSearchBtn() {
    return ElevatedButton.icon(
        onPressed: () => _searchPopup(),
        icon: Icon(Icons.search_outlined),
        label: Text("Search"));
  }

  // If no result is not found, then display
  // Design change
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
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
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
    final void Function(BuildContext, BabylonUser) pressedFunction) {
    // Function to create a small, styled button for each action.
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0),
      child: ElevatedButton.icon(
        onPressed: () => pressedFunction(context, person),
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

  // Display related users under search bar
  Widget _displaySearchedUsers(final index){
    final BabylonUser person = searchResults[index];
    return Card(
      margin: 
        EdgeInsets.symmetric(horizontal:12.0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0)),
      elevation: 3.0,
      child: GestureDetector(
        onTap: () {
          pressedProfileButton(context, person);
        },
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: ImageLoader.loadProfilePicture(person.imagePath, 30),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 10.0, right: 10.0, bottom: 10.0
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(person.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0
                      )),
                      SizedBox(height: 5),
                      Text(person.about ?? "",
                          style: TextStyle(fontSize: 14.0))
                    ],
                  ),
                ),
              ),
        ])),
      )
    );
  }

  // Pop up a dialog window for searching users
  Future<void> _searchPopup() async {
    if (_isSearchedUsersShowing) {
        return;
    }

    setState(() {
        _isSearchedUsersShowing = true;
    });

    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (final BuildContext context) {
            return StatefulBuilder(
                builder: (final BuildContext context, final StateSetter dialogSetState) {
                    return Dialog(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                                Row(
                                    children: [
                                        Expanded(
                                            child: Container(
                                                margin: EdgeInsets.only(top: 18, left: 8, bottom: 8),
                                                width: 250,
                                                height: 30,
                                                child: TextField(
                                                    autofocus: true,
                                                    onChanged: (final value) async {
                                                        if (value.isEmpty) {
                                                            dialogSetState(() {
                                                                searchResults = [];
                                                            });
                                                        } else {
                                                            try {
                                                                final List<BabylonUser> searchResultsTemp = await UserService.searchBabylonUsers(value);
                                                                final String currentUserUID = ConnectedBabylonUser().userUID;
                                                                dialogSetState(() {
                                                                    searchResults = searchResultsTemp.where((final user) => user.userUID != currentUserUID).toList();
                                                                });
                                                            } catch (error) {
                                                                print(error);
                                                            }
                                                        }
                                                    },
                                                    controller: searchController,
                                                    decoration: InputDecoration(
                                                        hintText: "Search...",
                                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                                                        // prefixIcon: Icon(Icons.search),
                                                    ),
                                                ),
                                            ),
                                        ),
                                        Container(
                                            margin: EdgeInsets.only(left: 8, bottom: 8, right: 10),
                                            alignment: Alignment.topRight,
                                            child: InkWell(
                                                onTap: () {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                        _isSearchedUsersShowing = false;
                                                    });
                                                },
                                                child: Icon(
                                                    color: Theme.of(context).colorScheme.primary,
                                                    Icons.close,
                                                    size: 30,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                                Expanded(
                                    child: searchResults.isEmpty && searchController.text.isNotEmpty
                                        ? _buildNoResultsFoundMessage()
                                        : ListView.builder(
                                            itemCount: searchResults.length,
                                            itemBuilder: (final context, final index) {
                                                return _displaySearchedUsers(index);
                                            },
                                        ),
                                ),
                            ],
                        ),
                    );
                },
            );
        },
    ).then((_) {
        setState(() {
            _isSearchedUsersShowing = false;
        });
    });
}



  
  @override
  Widget build(final BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMyConnectionsDataLoading) ...{
          _buildSearchBtn(),
          // _buildNewUsers(),
        } else
          Center(child: Loading())
      ],
    ));
  }


}


