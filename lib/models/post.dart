class Post {
  // Attributes

  List<Object?> categories;
  String title;
  String excerpt;
  String url;
  String featuredImageURL;

  // Constructors

  Post(
      {required this.categories,
      required this.title,
      required this.excerpt,
      required this.featuredImageURL,
      required this.url});
}

class PaginatedPosts {
  final Map<String, dynamic> paginationInfo;
  final List<Post> posts;

  PaginatedPosts({required this.paginationInfo, required this.posts});
}
