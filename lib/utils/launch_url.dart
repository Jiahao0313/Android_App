// Method to launch the URL
import "package:url_launcher/url_launcher.dart";

void goToUrl(final String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    // Check if the URL can be launched
    throw "Could not launch $uri";
  }
}
