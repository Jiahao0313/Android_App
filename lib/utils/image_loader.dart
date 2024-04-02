import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class ImageLoader { // TODO(EnzoL): there is a bug for the first time you load the image where it displays as blue
  static Widget withFallback(final String imagePath) => FutureBuilder(
        future: _futureAssetWithFallback(imagePath),
        builder: (final BuildContext context, final snapshot) =>
            snapshot.data ??
            Image(image: CachedNetworkImageProvider(imagePath)),
      );

  static Widget loadProfilePicture(final String imagePath, final double radius) => FutureBuilder(
        future: _futureAssetForProfilePicture(imagePath),
        builder: (final BuildContext context, final snapshot) => CircleAvatar(
          radius: radius,
          backgroundImage: snapshot.data ?? Image(image: CachedNetworkImageProvider(imagePath)).image, // Display user"s profile picture.
        ),
      );

  static Future<Widget> _futureAssetWithFallback(
          final String imagePath) async =>
      (await isNetworkAsset(imagePath))
          ? Image.network(imagePath)
          : Image.asset("assets/images/default_user_logo.png");

  static Future<ImageProvider<Object>> _futureAssetForProfilePicture(
       final String imagePath) async =>
      (await isNetworkAsset(imagePath))
          ? Image.network(imagePath).image
          : Image.asset("assets/images/default_user_logo.png").image;

  static Future<bool> isNetworkAsset(final String networkPath) async {
    try {
      await NetworkAssetBundle(Uri.parse(networkPath)).load(networkPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}
