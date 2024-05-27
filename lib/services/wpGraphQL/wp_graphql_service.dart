import "package:babylon_app/models/post.dart";
import "package:graphql_flutter/graphql_flutter.dart";

class WpGraphQLService {
  static Future<PaginatedPosts> getNewPosts({final int number = 5}) async {
    try {
      final List<Post> featchedPosts = List.empty(growable: true);

      final HttpLink httpLink = HttpLink("https://babylonradio.com/graphql");
      final GraphQLClient client = GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(),
      );
      final String getFirstPosts = """
        query getFirstPosts {
          posts(first: ${number}) {
            pageInfo{
              hasNextPage
              endCursor
            }
            nodes {
              title
              featuredImage {
                node {
                  sourceUrl
                }
              }
              excerpt
              uri
              author {
                node {
                  avatar {
                    url
                  }
                  name
                }
              }
              categories {
                nodes {
                  name
                }
              }
            }
          }
        }""";
      final QueryOptions options = QueryOptions(
        document: gql(getFirstPosts),
      );

      final QueryResult response = await client.query(options);

      final List<Object?> responsePosts = response.data?["posts"]?["nodes"];
      final Map<String, dynamic> paginationData =
          response.data?["posts"]?["pageInfo"];

      responsePosts.forEach((final aPost) {
        final postMap = aPost as Map<String, dynamic>;
        featchedPosts.add(Post(
          categories: postMap["categories"]?["nodes"] ?? [],
          title: postMap["title"] ?? [],
          excerpt: postMap["excerpt"] ?? "",
          featuredImageURL:
              postMap["featuredImage"]?["node"]?["sourceUrl"] ?? "",
          url: postMap["uri"] ?? "",
        ));
      });

      return PaginatedPosts(
          paginationInfo: paginationData, posts: featchedPosts);
    } catch (e) {
      rethrow;
    }
  }

  static Future<PaginatedPosts> getMorePosts(
      final int postQuantity, final String endCursor) async {
    try {
      final List<Post> featchedPosts = List.empty(growable: true);

      final HttpLink httpLink = HttpLink("https://babylonradio.com/graphql");
      final GraphQLClient client = GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(),
      );
      final String getMorePosts = """
        query getMorePosts {
          posts(first: ${postQuantity}, after: ${endCursor}) {
            pageInfo{
              hasNextPage
              endCursor
            }
            nodes {
              title
              featuredImage {
                node {
                  sourceUrl
                }
              }
              excerpt
              uri
              author {
                node {
                  avatar {
                    url
                  }
                  name
                }
              }
              categories {
                nodes {
                  name
                }
              }
            }
          }
        }""";
      final QueryOptions options = QueryOptions(
        document: gql(getMorePosts),
      );

      final QueryResult response = await client.query(options);

      final List<Object?> responsePosts = response.data?["posts"]?["nodes"];
      final Map<String, dynamic> paginationData =
          response.data?["posts"]?["pageInfo"];

      responsePosts.forEach((final aPost) {
        final postMap = aPost as Map<String, dynamic>;
        featchedPosts.add(Post(
          categories: postMap["categories"]?["nodes"] ?? [],
          title: postMap["title"] ?? [],
          excerpt: postMap["excerpt"] ?? "",
          featuredImageURL:
              postMap["featuredImage"]?["node"]?["sourceUrl"] ?? "",
          url: postMap["uri"] ?? "",
        ));
      });

      return PaginatedPosts(
          paginationInfo: paginationData, posts: featchedPosts);
    } catch (e) {
      rethrow;
    }
  }
}
