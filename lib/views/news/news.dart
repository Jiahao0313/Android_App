import "package:babylon_app/models/post.dart";
import "package:babylon_app/services/wpGraphQL/wp_graphql_service.dart";
import "package:babylon_app/utils/html_strip.dart";
import "package:babylon_app/utils/launch_url.dart";
import "package:babylon_app/views/loading.dart";
import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final scrollController = ScrollController();
  // late TabController _tabController;
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

    // lazy loading WIP
    // scrollController.addListener(() {
    //   if (scrollController.position.maxScrollExtent ==
    //       scrollController.position.pixels) {
    //     if (_tabController.index == 0 && !loadingPosts && !loadingMorePosts) {
    //       print("teste!");
    //       getMorePosts();
    //     }
    //   }
    // });
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: "News"),
        body: Builder(builder: (final BuildContext context) {
          List<Widget> children;
          if (loadingPosts) {
            children = <Widget>[Loading()];
          } else if (loadedPosts.isNotEmpty) {
            children = <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 24),
                  child: Text(
                    "Latest news",
                    style: Theme.of(context).textTheme.titleSmall,
                  )),
              ...loadedPosts.map((final aPost) => _buildNewsCard(aPost))
            ];
          } else if (loadedPosts.isEmpty) {
            children = <Widget>[
              Center(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 20.0), // Adjust the top margin here
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
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
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
        }));
  }

  Widget _buildNewsCard(final Post aPost) {
    return Container(
        margin: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () => goToUrl(
              "https://babylonradio.com/${aPost.url}"), // Acción al tocar la tarjeta completa.
          child: Card(
            surfaceTintColor: Theme.of(context).colorScheme.background,
            elevation: 10,
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.zero)),
            child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        flex: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(aPost.featuredImageURL,
                              fit: BoxFit.cover, height: 100, errorBuilder:
                                  (final BuildContext context,
                                      final Object exception,
                                      final StackTrace? stackTrace) {
                            // Here you can return the default image widget
                            return Image.asset("assets/images/newsphoto.png",
                                fit: BoxFit.cover);
                          }),
                        )),
                    Expanded(
                        flex: 6,
                        child: Container(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Text(aPost.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                                Container(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Text(stripHtml(aPost.excerpt),
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis)),
                                Container(
                                    padding: EdgeInsets.only(right: 8, top: 8),
                                    alignment: Alignment.topRight,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                            textStyle: MaterialStatePropertyAll(
                                                Theme.of(context)
                                                    .textTheme
                                                    .titleSmall),
                                            padding: MaterialStatePropertyAll(
                                                EdgeInsets.symmetric(
                                                    vertical: 2,
                                                    horizontal: 12)),
                                            backgroundColor:
                                                MaterialStatePropertyAll(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                        onPressed: () => goToUrl(
                                            "https://babylonradio.com/${aPost.url}"),
                                        child: Text("Read more")))
                              ],
                            ))),
                  ],
                )),
          ),
        ));
  }
}
