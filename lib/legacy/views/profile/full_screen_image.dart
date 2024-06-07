import "package:babylon_app/utils/image_loader.dart";
import "package:flutter/material.dart";

class FullScreenImage extends StatelessWidget {
  final String
      imagePath; // Path to the image that will be displayed in full screen.
  final String name; // Name of the person to be displayed in the AppBar.

  // Constructor requiring the image path and the person"s name.
  const FullScreenImage(
      {super.key, required this.imagePath, required this.name});

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      // AppBar configuration
      appBar: AppBar(
        title: 
        Text(name,
          style: TextStyle(color: Colors.green),
        ), // Display the person"s name in the AppBar.
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // Icon for the back button.
          onPressed: () => Navigator.pop(
              context), // Action to return to the previous screen when the back button is pressed.
        ),
      ),
      backgroundColor:
          Colors.black, // Sets the background color of the screen to black.
      body: GestureDetector(
        onTap: () => Navigator.pop(
            context), // Allows closing the image by tapping anywhere on the screen.
        child: Center(
          child: ImageLoader.withFallback(imagePath), // Displays the image in full screen, fitting it to the screen while maintaining the aspect ratio.
        ),
      ),
    );
  }
}
