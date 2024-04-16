import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});
  // The URL you want to open
  static final Uri _url =
      Uri.parse("https://www.mixcloud.com/live/BabylonRadio/");

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text("Radio"),
            SizedBox(
              height: 55,
              width: 55,
              child: Image.asset("assets/images/logowhite.png"),
            ),
          ],
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xff3A82B9), // Light blue for the top part
            ),
          ),
          Container(
            width: MediaQuery.of(context)
                .size
                .width, // Make the image cover the full width
            child: InkWell(
              onTap:
                  _launchURL, // Calls the _launchURL method when the image is tapped
              child: Image.asset(
                "assets/images/photoradio.png",
                fit: BoxFit
                    .cover, // Cover the container without distorting the aspect ratio
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Color(0xff5065A5), // Dark blue for the bottom part
            ),
          ),
        ],
      ),
    );
  }

  // Method to launch the URL
  void _launchURL() async {
    if (!await launchUrl(_url)) {
      // Checks if the URL can be launched
      throw "Could not launch $_url";
    }
  }
}
