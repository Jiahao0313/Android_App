// import "package:babylon_app/models/post.dart";
// import "package:babylon_app/services/wpGraphQL/wp_graphql_service.dart";
// import "package:babylon_app/utils/html_strip.dart";
// import "package:babylon_app/utils/launch_url.dart";
// import "package:flutter/material.dart";

// class NewsScreen extends StatelessWidget {
//   const NewsScreen({super.key});

//   @override
//   Widget build(final BuildContext context) {
//     return const MaterialApp(
//       home: FutureBuilderNews(),
//     );
//   }
// }

// class FutureBuilderNews extends StatefulWidget {
//   const FutureBuilderNews({super.key});

//   @override
//   State<FutureBuilderNews> createState() => _FutureBuilderNewsState();
// }

// class _FutureBuilderNewsState extends State<FutureBuilderNews> {
//   final Future<List<Post>> _posts = WpGraphQLService.getNewPosts();

//   @override
//   Widget build(final BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: <Widget>[
//               const Text("News"),
//               SizedBox(
//                 height: 55,
//                 width: 55,
//                 child: Image.asset("assets/images/logowhite.png"),
//               ),
//             ],
//           ),
//           backgroundColor: Colors.green,
//         ),
//         body: DefaultTextStyle(
//           style: Theme.of(context).textTheme.displayMedium!,
//           textAlign: TextAlign.center,
//           child: FutureBuilder<List<Post>>(
//             future: _posts, // a previously-obtained Future<String> or null
//             builder: (final BuildContext context,
//                 final AsyncSnapshot<List<Post>> snapshot) {
//               List<Widget> children;
//               if (snapshot.hasData) {
//                 children = <Widget>[
//                   Padding(
//                     padding: EdgeInsets.only(left: 16, top: 16),
//                     child: Text("Latest news",
//                         textAlign: TextAlign.left,
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                   ),
//                   ...snapshot.data!.map((final aPost) => GestureDetector(
//                         onTap: () => goToUrl(
//                             "https://babylonradio.com/${aPost.url}"), // Acción al tocar la tarjeta completa.
//                         child: Card(
//                           margin: EdgeInsets.all(16),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: EdgeInsets.only(left: 8, top: 16),
//                                 child: ClipRRect(
//                                   borderRadius:
//                                       BorderRadius.circular(20), // Image border
//                                   child: SizedBox.fromSize(
//                                     size: Size.fromRadius(50), // Image radius
//                                     child: Image.network(aPost.featuredImageURL,
//                                         fit: BoxFit.cover, errorBuilder:
//                                             (final BuildContext context,
//                                                 final Object exception,
//                                                 final StackTrace? stackTrace) {
//                                       // Here you can return the default image widget
//                                       return Image.asset(
//                                           "assets/images/newsphoto.png",
//                                           fit: BoxFit.cover);
//                                     }),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                   child: Padding(
//                                 padding: EdgeInsets.all(16),
//                                 child: Column(children: [
//                                   Text(
//                                     aPost.title,
//                                     style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(stripHtml(aPost.excerpt),
//                                       style: TextStyle(fontSize: 12),
//                                       maxLines: 3,
//                                       overflow: TextOverflow.ellipsis),
//                                   Align(
//                                     alignment: Alignment.centerRight,
//                                     heightFactor: 1.4,
//                                     child: TextButton(
//                                       onPressed: () => goToUrl(
//                                           "https://babylonradio.com/${aPost.url}"),
//                                       style: TextButton.styleFrom(
//                                           foregroundColor: Colors.white,
//                                           elevation: 2,
//                                           backgroundColor: Color(0xFF006400)),
//                                       child: Text("READ",
//                                           textAlign: TextAlign.right),
//                                     ),
//                                   )
//                                 ]),
//                               ))
//                             ],
//                           ),
//                         ),
//                       )),
//                 ];
//               } else if (snapshot.hasError) {
//                 children = <Widget>[
//                   const Icon(
//                     Icons.error_outline,
//                     color: Colors.red,
//                     size: 60,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: Text("Error: ${snapshot.error}"),
//                   ),
//                 ];
//               } else {
//                 children = <Widget>[
//                   Column(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.only(top: 16),
//                         child: SizedBox(
//                           width: 60,
//                           height: 60,
//                           child: CircularProgressIndicator(
//                               color: Color(0xFF006400)),
//                         ),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 16),
//                         child: Text("Loading..."),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.only(top: 128),
//                         child: Image.asset("assets/images/logoSquare.png",
//                             height: 185, width: 185),
//                       ),
//                     ],
//                   )
//                 ];
//               }
//               return ListView(
//                 children: children,
//               );
//             },
//           ),
//         ));
//   }
// }
