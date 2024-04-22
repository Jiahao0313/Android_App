import "package:babylon_app/views/navigation/custom_app_bar.dart";
import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";

class RadioScreen extends StatelessWidget {
  const RadioScreen({super.key});

  static final Uri url =
      Uri.parse("https://www.mixcloud.com/live/BabylonRadio/");

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Radio"),
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
              onTap: () => launchUrl(
                  url), // Calls the _launchURL method when the image is tapped
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
}
