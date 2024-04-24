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
            child: TabBarView(
                controller: _tabController,
                children: [_buildMyConnections(), Text("o")]),
          )
        ]));
  }

  Widget _buildMyConnections() {
    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        isMyConnectionsDataLoading
            ? Expanded(child: Center(child: Loading()))
            : _buildRecievedFriendRequestList(),
        _buildSentFriendRequestList(),
        _buildFriendsGrid()
      ],
    ));
  }

  Widget _buildRecievedFriendRequestList() {
    return Column(
      children: [
        if (recievedFriendRequests.isNotEmpty) ...{
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

  Widget _buildSentFriendRequestList() {
    return Column(
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
                    CircleAvatar(foregroundImage: NetworkImage(user.imagePath)),
                    Text(user.fullName),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            // TODO
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
                        },
                        if (userTile == UserTile.recievedFriendRequest) ...{
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
                        },
                        if (userTile == UserTile.sentFriendRequest)
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
}
