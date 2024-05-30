import "package:babylon_app/legacy/views/chat/chat_view.dart";
import "package:babylon_app/legacy/views/profile/other_profile.dart";
import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/models/chat.dart";
import "package:babylon_app/models/connected_babylon_user.dart";
import "package:babylon_app/services/chat/chat_service.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/utils/image_loader.dart";
import "package:babylon_app/views/loading.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:babylon_app/views/profile/user_profile.dart";
import "package:flutter/animation.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'dart:ui';
import "package:flutter/widgets.dart";
import "package:babylon_app/views/community/search_user.dart";

enum UserTile { friend, recievedFriendRequest, sentFriendRequest, newUser }

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _Community();
}

class _Community extends State<Community> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  late List<BabylonUser> myFriends = [];
  late List<BabylonUser> recievedFriendRequests = [];
  late List<BabylonUser> sentFriendRequests = [];
  late List<BabylonUser> newUsers = [];
  late List<BabylonUser> searchResults = [];
  late bool isMyConnectionsDataLoading;
  late bool _isSearchedUsersShowing = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    fetchMyFriends();
    fetchRecievedFriendRequests();
    fetchSentFriendRequests();
    fetchNewUsers();
    // searchController.addListener(() {
    //   fetchSearchUsers(searchController.text);
    // });
  }

  void dispose() {
    _tabController.dispose();
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

  void fetchRecievedFriendRequests() async {
    try {
      setState(() {
        isMyConnectionsDataLoading = true;
      });
      final List<BabylonUser> friendRequests =
          await UserService.getConnectionsRequests();
      setState(() {
        recievedFriendRequests.addAll(friendRequests);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isMyConnectionsDataLoading = false;
      });
    }
  }

  void fetchSentFriendRequests() async {
    try {
      setState(() {
        isMyConnectionsDataLoading = true;
      });
      final List<BabylonUser> friendRequestSent =
          await UserService.getConnectionsRequests();
      setState(() {
        sentFriendRequests.addAll(friendRequestSent);
      });
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        isMyConnectionsDataLoading = false;
      });
    }
  }

  void fetchNewUsers() async {
    try {
      final List<BabylonUser> fetchedNewUsers =
          await UserService.getNewUsers(number: 5);
      setState(() {
        newUsers.addAll(fetchedNewUsers);
      });
    } catch (e) {
      rethrow;
    }
  }

  // Fetch users when inputing 
  // void fetchSearchUsers(final String query) async {

  //   if(query.isEmpty) {
  //     final allUsers = await UserService.getAllBabylonUsers();
  //     final currentUserUID = ConnectedBabylonUser().userUID;

  //     setState(() {
  //       searchResults = allUsers
  //           .where((final user) => user.userUID != currentUserUID)
  //           .toList();
  //     }); 
  //   } else {
  //     // print for TEST
  //     print("!!!!!!!!!!!!Searching for $query!!!!!!!!!!!!!!!!!!!!");
  //     final searchResultsTemp = await UserService.searchBabylonUsers(query);
  //     final currentUserUID = ConnectedBabylonUser().userUID;

  //     setState(() {
  //       // print for TEST
  //       print("----------------------------Have Added--------------------------");
  //       searchResults = searchResultsTemp
  //           .where((final user) => user.userUID != currentUserUID)
  //           .toList();

  //           // UI update in real time?
  //           // _searchPopup();
  //           _displaySearchedUsers(0);
  //       print(searchResults);
  //     });
  //   }
  // }

  // void _onSearchChanged() {
  //   String query = searchController.text;
  //   setState(() {
  //     _searchResults = 
  //   });
  // }

    void pressedProfileButton(final BabylonUser babylonUser) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (final context) => UserProfile(user: babylonUser)),
      );
    }

  void pressedRequestButton(final BabylonUser babylonUser) {
    UserService.sendConnectionRequest(requestUID: babylonUser.userUID);
    setState(() {
      searchResults
          .firstWhere((final search) => babylonUser.userUID == search.userUID)
          .connectionRequestsUIDs!
          .add(ConnectedBabylonUser().userUID);
    });
  }

  void pressedChatButton(final BabylonUser babylonUser) async {
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

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "Community"),
        body: Column(mainAxisSize: MainAxisSize.max, children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "My Connections"),
              Tab(text: "Discover People")
            ],
          ),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(right: 16, left: 16, bottom: 16),
            child: TabBarView(
                controller: _tabController,
                children: [_buildMyConnections(), Search()]),
          ))
        ]));
  }

  Widget _buildMyConnections() {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMyConnectionsDataLoading) ...{
          _buildRecievedFriendRequestList(),
          _buildSentFriendRequestList(),
          _buildFriendsGrid()
        } else
          Center(child: Loading())
      ],
    ));
  }

  // Widget _buildDiscoverPeople() {
  //   return SingleChildScrollView(
  //       child: Column(
  //     mainAxisSize: MainAxisSize.min,
  //     children: [
  //       if (!isMyConnectionsDataLoading) ...{
  //         _buildSearchBtn(),
  //         _buildNewUsers(),
  //       } else
  //         Center(child: Loading())
  //     ],
  //   ));
  // }

  Widget _buildRecievedFriendRequestList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recievedFriendRequests.isNotEmpty) ...{
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 24, right: 24, top: 24),
              child: Text(
                "Recieved friend requests",
                style: Theme.of(context).textTheme.titleMedium,
              )),
          Container(
            height: 200,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...recievedFriendRequests.map((final aRecievedFriendRequest) =>
                    _buildUserTile(
                        user: aRecievedFriendRequest,
                        userTile: UserTile.recievedFriendRequest))
              ],
            ),
          )
        }
      ],
    );
  }

  Widget _buildSentFriendRequestList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sentFriendRequests.isNotEmpty) ...{
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 24, right: 24, top: 24),
              child: Text(
                "Sent friend requests",
                style: Theme.of(context).textTheme.titleMedium,
              )),
          Container(
            height: 200,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ...sentFriendRequests.map((final aSentFriendRequest) =>
                    _buildUserTile(
                        user: aSentFriendRequest,
                        userTile: UserTile.sentFriendRequest))
              ],
            ),
          )
        }
      ],
    );
  }

  Widget _buildFriendsGrid() {
    return Column(
      children: [
        if (sentFriendRequests.isNotEmpty) ...{
          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 24, right: 24, top: 24),
              child: Text(
                "Friends",
                style: Theme.of(context).textTheme.titleMedium,
              )),
          Container(
            height: (myFriends.length % 2 + 1) * 210,
            child: GridView.count(
              crossAxisCount: 2,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ...myFriends.map((final aFriend) =>
                    _buildUserTile(user: aFriend, userTile: UserTile.friend))
              ],
            ),
          )
        }
      ],
    );
  }

  // Widget _buildSearchBtn() {
  //   return ElevatedButton.icon(
  //       onPressed: () => _searchPopup(),
  //       icon: Icon(Icons.search_outlined),
  //       label: Text("Search"));
  // }

  // Widget _buildNewUsers() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (recievedFriendRequests.isNotEmpty) ...{
  //         Container(
  //             alignment: Alignment.centerLeft,
  //             padding: EdgeInsets.only(left: 24, right: 24, top: 24),
  //             child: Text(
  //               "Recieved friend requests",
  //               style: Theme.of(context).textTheme.titleMedium,
  //             )),
  //         Container(
  //           height: 200,
  //           child: ListView(
  //             shrinkWrap: true,
  //             scrollDirection: Axis.horizontal,
  //             children: [
  //               ...newUsers.map((final aNewUser) =>
  //                   _buildUserTile(user: aNewUser, userTile: UserTile.newUser))
  //             ],
  //           ),
  //         )
  //       }
  //     ],
  //   );
  // }

  // Creating the search bar for discovering people
  // Widget _buildSearchBar() {
  //   return Container(
  //     margin: EdgeInsets.only(top: 8, left: 10, bottom: 8),
  //     width: 250,
  //     height: 30,
  //     child: SearchBar(
  //       autoFocus: true,
  //       onChanged: fetchSearchUsers,
  //       controller: searchController,

  //     ),
  //   ); 
  // }

  // If no result is not found, then display
  // Design change
  // Widget _buildNoResultsFoundMessage() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Icon(Icons.search_off, size: 80, color: Colors.grey[600]),
  //         SizedBox(
  //             height: 20), // Provides spacing between the icon and the text.
  //         Text(
  //           "No people found with that name.",
  //           style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
  //           textAlign: TextAlign.center,
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  // Display related users under search bar
  // Widget _displaySearchedUsers(final index){
  //   final BabylonUser person = searchResults[index];
  //   return Card(
  //     margin: 
  //       EdgeInsets.symmetric(horizontal:12.0, vertical: 6.0),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(8.0)),
  //     elevation: 3.0,
  //     child: IntrinsicHeight(
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           GestureDetector(
  //             onTap: () {
  //               Navigator.push(
  //                 context, 
  //                 MaterialPageRoute(
  //                   builder: (final context) => 
  //                       OtherProfile(babylonUser: person))
  //               );
  //             },
  //             child: Padding(
  //               padding: EdgeInsets.all(8.0),
  //               child: ImageLoader.loadProfilePicture(person.imagePath, 30),
  //             ),
  //           ),
  //       Expanded(
  //         child: Padding(
  //           padding: EdgeInsets.only(
  //             top: 10.0, right: 10.0, bottom: 10.0
  //           ),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(person.fullName,
  //               style: TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 16.0
  //               )),
  //               SizedBox(height: 5),
  //               Text(person.about ?? "",
  //                   style: TextStyle(fontSize: 14.0))
  //             ],
  //           ),
  //         ),
  //       ),
  //       // VerticalDivider(),
  //       Padding(
  //         padding: EdgeInsets.symmetric(vertical: 8.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             _buttonOption(
  //                 "View Profile",
  //                 Icons.visibility,
  //                 context,
  //                 person,
  //                 pressedProfileButton),
  //             _buttonOption(
  //                 person.connectionRequestsUIDs!.any(
  //                         (final userUID) =>
  //                             userUID ==
  //                             ConnectedBabylonUser()
  //                                 .userUID)
  //                     ? "Pending"
  //                     : "Send Request",
  //                 Icons.person_add,
  //                 context,
  //                 person,
  //                 pressedRequestButton),
  //             _buttonOption("Chat", Icons.chat, context,
  //                 person, pressedChatButton),
  //           ],
  //         ),
  //       )
  //       ])),
  //   );
  // }

  Widget _buildUserTile(
      {required final BabylonUser user, required final UserTile userTile}
  ){
    return SizedBox(
        width: 200,
        child: Card(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 28),
                child: Column(
                  children: [
                    CircleAvatar(
                        foregroundImage: NetworkImage(user.imagePath),
                        radius: 40),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Text(user.fullName)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            await _userPopup(popupType: userTile, user: user);
                          },
                          child: Icon(
                            Icons.visibility_outlined,
                            color: userTile == UserTile.friend
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        if (userTile == UserTile.friend) ...{
                          InkWell(
                            onTap: () {
                              // TODO
                            },
                            child: Icon(Icons.person_remove_outlined,
                                color: Theme.of(context).colorScheme.error),
                          ),
                          InkWell(
                            onTap: () {
                              // TODO
                            },
                            child: Icon(Icons.chat_outlined,
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                        } else if (userTile ==
                            UserTile.recievedFriendRequest) ...{
                          InkWell(
                            onTap: () {
                              // TODO
                            },
                            child: Icon(Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.primary),
                          ),
                          InkWell(
                            onTap: () {
                              // TODO
                            },
                            child: Icon(Icons.cancel_outlined,
                                color: Theme.of(context).colorScheme.error),
                          )
                        } else if (userTile == UserTile.sentFriendRequest)
                          InkWell(
                            onTap: () {
                              // TODO
                            },
                            child: Icon(Icons.cancel_schedule_send_outlined,
                                color: Theme.of(context).colorScheme.error),
                          ),
                      ],
                    )
                  ],
                ))));
  }

  Future<void> _userPopup(
      {required final UserTile popupType,
      required final BabylonUser user}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (final BuildContext context) {
        return Dialog(
          child: Container(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              margin: EdgeInsets.only(top: 16, right: 16),
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  color: Theme.of(context).colorScheme.primary,
                  Icons.close,
                  size: 30,
                ),
              ),
            ),
            CircleAvatar(
              radius: 100,
              foregroundImage: user.imagePath != ""
                  ? NetworkImage(user.imagePath)
                  : AssetImage("assets/images/default_user_logo.png")
                      as ImageProvider,
            ),
            Container(
              margin: EdgeInsets.only(top: 12),
              child: Text(
                user.fullName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (user.originCountry != null || user.originCountry == "")
              Container(
                margin: EdgeInsets.only(top: 12),
                child: Text(user.originCountry!),
              ),
            if (user.dateOfBirth != null || user.dateOfBirth == "")
              Container(
                margin: EdgeInsets.only(top: 12),
                child: Text(user.dateOfBirth!),
              ),
            if (user.about != null || user.about == "") ...{
              Container(
                margin: EdgeInsets.only(top: 24),
                child: Text("About me",
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                child: Text(user.about!),
              )
            },
            Container(
                margin: EdgeInsets.only(top: 12, bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (popupType == UserTile.friend) ...{
                      InkWell(
                          onTap: () {
                            // TODO
                          },
                          child: Column(
                            children: [
                              Icon(Icons.person_remove_outlined,
                                  color: Theme.of(context).colorScheme.error),
                              Text(
                                "Remove Friend",
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              )
                            ],
                          )),
                      InkWell(
                          onTap: () {
                            // TODO
                          },
                          child: Column(
                            children: [
                              Icon(Icons.chat_outlined,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              Text(
                                "Start a Chat",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              )
                            ],
                          )),
                    } else if (popupType == UserTile.recievedFriendRequest) ...{
                      InkWell(
                          onTap: () {
                            // TODO
                          },
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Theme.of(context).colorScheme.primary),
                              Text(
                                "Accept",
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              )
                            ],
                          )),
                      InkWell(
                          onTap: () {
                            // TODO
                          },
                          child: Column(
                            children: [
                              Icon(Icons.cancel_outlined,
                                  color: Theme.of(context).colorScheme.error),
                              Text(
                                "Decline",
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              )
                            ],
                          ))
                    } else if (popupType == UserTile.sentFriendRequest)
                      InkWell(
                          onTap: () {
                            // TODO
                          },
                          child: Column(
                            children: [
                              Icon(Icons.cancel_schedule_send_outlined,
                                  color: Theme.of(context).colorScheme.error),
                              Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              )
                            ],
                          )),
                  ],
                ))
          ])),
        );
      },
    );
  }

  // Pop up a dialog window for searching users
  // Future<void> _searchPopup() async {
  //   if(_isSearchedUsersShowing) {
  //     return;
  //   }

  //   setState(() {
  //     _isSearchedUsersShowing = true;
  //     // _isDialogOpen = true;
  //   });

  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (final BuildContext context) {

  //     final bool hasSearchQuery = searchController.text.isNotEmpty;
  //       return Dialog(
  //         child: Column(mainAxisSize: MainAxisSize.min, children: [
  //           Row(children: [
  //             Expanded(child:_buildSearchBar()), // Search Bar  
  //             Container(
  //               margin: EdgeInsets.only(left: 8, top: 8, bottom: 8),
  //               alignment: Alignment.topRight,
  //               child: InkWell(
  //                 onTap: () => {
  //                   Navigator.of(context).pop(),
  //                   setState(() {
  //                     _isSearchedUsersShowing = false;
  //                     print("NOT SHOWING");
  //                   }),
  //                 },
  //                   child: 
  //                     Icon(
  //                       color: Theme.of(context).colorScheme.primary,
  //                       Icons.close,
  //                       size: 30,
  //                     )
  //                 ),
  //               ),
  //             ]),
  //             Expanded(
  //               child: searchResults.isEmpty && hasSearchQuery
  //                 ? _buildNoResultsFoundMessage()
  //                 : ListView.builder(
  //                     itemCount: searchResults.length,
  //                     itemBuilder: (final context, final index){
  //                       return _displaySearchedUsers(index);
  //                     }
  //                   )
  //             )
  //           ]
  //         ),
  //       );
  //     },
  //   );
  // }
}
