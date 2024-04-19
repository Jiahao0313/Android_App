import "package:flutter/material.dart";

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final scrollController = ScrollController();
  late TabController _tabController;
  late List<Post> loadedPosts = [];
  late bool loadingPosts = false;
  late bool loadingMorePosts = false;
  late String currentPageCursor;

  String formatedCategories(final categories) {
    return categories.map((final category) => category["name"]).join(", ");
  }

  void getPosts() async {
    try {
      setState(() {
        loadingPosts = true;
      });

      final response = await WpGraphQLService.getNewPosts();
      loadedPosts.addAll(response.posts);
      response.paginationInfo["endCursor"];
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        loadingPosts = false;
      });
    }
  }

  //To-do (Lazy loading)
  void getMorePosts() async {
    try {
      setState(() {
        loadingMorePosts = true;
      });

      final response =
          await WpGraphQLService.getMorePosts(5, currentPageCursor);
      loadedPosts.addAll(response.posts);
      currentPageCursor = response.paginationInfo["endCursor"];
    } catch (error) {
      print(error);
    } finally {
      setState(() {
        loadingMorePosts = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getPosts();

    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (_tabController.index == 0 && !loadingPosts && !loadingMorePosts) {
          print("teste!");
          getMorePosts();
        }
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text("News"),
              SizedBox(
                height: 55,
                width: 55,
                child: Image.asset("assets/images/logowhite.png"),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
        body: DefaultTextStyle(
            style: Theme.of(context).textTheme.displayMedium!,
            textAlign: TextAlign.center,
            child: Builder(builder: (final BuildContext context) {
              List<Widget> children;
              if (loadingPosts) {
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
              } else if (loadedPosts.isNotEmpty) {
                children = <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text("Latest news",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...loadedPosts.map((final aPost) => GestureDetector(
                        onTap: () => goToUrl(
                            "https://babylonradio.com/${aPost.url}"), // Acción al tocar la tarjeta completa.
                        child: Card(
                          margin: EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 8, top: 16),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(20), // Image border
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(50), // Image radius
                                    child: Image.network(aPost.featuredImageURL,
                                        fit: BoxFit.cover, errorBuilder:
                                            (final BuildContext context,
                                                final Object exception,
                                                final StackTrace? stackTrace) {
                                      // Here you can return the default image widget
                                      return Image.asset(
                                          "assets/images/newsphoto.png",
                                          fit: BoxFit.cover);
                                    }),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(children: [
                                  Text(formatedCategories(aPost.categories)),
                                  Text(
                                    aPost.title,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(stripHtml(aPost.excerpt),
                                      style: TextStyle(fontSize: 12),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    heightFactor: 1.4,
                                    child: TextButton(
                                      onPressed: () => goToUrl(
                                          "https://babylonradio.com/${aPost.url}"),
                                      style: TextButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          backgroundColor: Color(0xFF006400)),
                                      child: Text("READ",
                                          textAlign: TextAlign.right),
                                    ),
                                  )
                                ]),
                              ))
                            ],
                          ),
                        ),
                      )),
                ];
              } else if (loadedPosts.isEmpty) {
                children = <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 20.0), // Adjust the top margin here
                      child: Text(
                        "We dont have any news... 😕",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ];
              } else {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text("Error"),
                  ),
                ];
              }
              return ListView(
                controller: scrollController,
                children: children,
              );
            })));
  }
}
