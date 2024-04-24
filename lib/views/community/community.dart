import "dart:math";

import "package:babylon_app/models/babylon_user.dart";
import "package:babylon_app/services/user/user_service.dart";
import "package:babylon_app/views/loading.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";

enum UserTile { friend, recievedFriendRequest, sentFriendRequest }

class Community extends StatefulWidget {
  const Community({super.key});
  @override
  State<Community> createState() => _Community();
}

class _Community extends State<Community> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final scrollController = ScrollController();
  late List<BabylonUser> myFriends = [];
  late List<BabylonUser> recievedFriendRequests = [];
  late List<BabylonUser> sentFriendRequests = [];
  late bool isMyConnectionsDataLoading;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    fetchMyFriends();
    fetchRecievedFriendRequests();
    fetchSentFriendRequests();
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
                children: [_buildMyConnections(), _buildDiscoverPeople()]),
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

  Widget _buildDiscoverPeople() {
    return Text("Discover");
  }

  Widget _buildUserTile(
      {required final BabylonUser user, required final UserTile userTile}) {
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
}
