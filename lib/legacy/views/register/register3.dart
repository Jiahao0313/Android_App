import "package:babylon_app/legacy/views/home.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:babylon_app/services/user/user_service.dart";

class RegisterPage3 extends StatefulWidget {
  const RegisterPage3({super.key});

  @override
  _RegisterPage3State createState() => _RegisterPage3State();
}

class _RegisterPage3State extends State<RegisterPage3> {
  // This list will hold the selected languages.
  List<String> selectedLanguages = [];
  // A list of languages that users can choose from.
  List<String> languages = [
    "Arabic",
    "Bengali",
    "Bosnian",
    "Bulgarian",
    "Cantonese",
    "Chinese",
    "Croatian",
    "Czech",
    "Danish",
    "Dutch",
    "English",
    "Finnish",
    "French",
    "German",
    "Greek",
    "Hebrew",
    "Hindi",
    "Hungarian",
    "Indonesian",
    "Italian",
    "Japanese",
    "Korean",
    "Malay",
    "Marathi",
    "Norwegian",
    "Pashto",
    "Persian",
    "Polish",
    "Portuguese",
    "Punjabi",
    "Romanian",
    "Russian",
    "Serbian",
    "Sindhi",
    "Slovak",
    "Spanish",
    "Swahili",
    "Swedish",
    "Tamil",
    "Telugu",
    "Thai",
    "Turkish",
    "Urdu",
    "Vietnamese"
  ];

  // Maps to manage the interests" selections.
  late Map<String, bool> interest1;
  late Map<String, bool> interest2;
  late Map<String, bool> interest3;

  @override
  void initState() {
    super.initState();
    // Initialize the interests with all options set to false (not selected).
    interest1 = {
      "hiking": false,
      "dancing": false,
      "football": false,
      "swimming": false,
      "singing": false,
      "cooking": false,
      "watching movies": false,
      "rugby": false,
      "board games": false,
      "Writing": false,
    };
    interest2 = {
      "EDM": false,
      "Pop": false,
      "K-pop": false,
      "House": false,
      "Rock": false,
      "Country": false,
    };
    interest3 = {
      "drawing": false,
      "ceramic": false,
      "reading": false,
      "Gaming": false,
    };
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Register"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image.asset("assets/images/logoRectangle.png",
                height: 90, width: 365),
            const SizedBox(height: 20),
            const Text(
              "Almost there, just a few more steps",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Tappable ListTile that opens the multi-select dialog.
            ListTile(
              title: Text("Select the languages that you speak"),
              subtitle: Text(
                selectedLanguages.isNotEmpty
                    ? selectedLanguages.join(", ")
                    : "None selected",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
              onTap: () => _showMultiSelectLanguages(context),
            ),
            // Building sections for interests
            _buildCheckboxGridSection("Activities", interest1),
            _buildCheckboxGridSection("Music", interest2),
            _buildCheckboxGridSection("Hobbies", interest3),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF006400),
                minimumSize: Size(365, 60), // Size of the button.
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      60.0), // Rounded edges for the button.
                ),
              ),
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;

                if (currentUser != null) {
                  await UserService.updateUserInfo(
                      uuid: currentUser.uid,
                      activities: interest1,
                      music: interest2,
                      hobbies: interest3);
                }

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (final context) => HomePage()),
                );
              },
              child: const Text(
                "Finish",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: "Lato",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // This function creates the multi-selection dialog for languages.
  void _showMultiSelectLanguages(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Select Languages"),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: languages.length,
              itemBuilder: (final ctx, final index) {
                return CheckboxListTile(
                  title: Text(languages[index]),
                  value: selectedLanguages.contains(languages[index]),
                  onChanged: (final bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedLanguages.add(languages[index]);
                      } else {
                        selectedLanguages.remove(languages[index]);
                      }
                    });
                    // Close and reopen the dialog to show the updated list.
                    Navigator.of(context).pop();
                    _showMultiSelectLanguages(context);
                  },
                );
              },
            ),
          ),
          actions: [
            // Closes the dialog when the "Done" button is pressed.
            TextButton(
              child: Text("Done"),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCheckboxGridSection(
      final String title, final Map<String, bool> options) {
    const int crossAxisCount = 2; // Number of columns in the grid

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        // Wrap the GridView with a Container for the background
        Container(
          decoration: BoxDecoration(
            // Use a BoxDecoration to style the background
            color: Color(0xFF006400).withOpacity(0.25),
            border: Border.all(
              color: Colors.black, // The color of the border
              width: 1, // The width of the border
            ),
            borderRadius: BorderRadius.circular(15), // The border radius
          ),
          padding: const EdgeInsets.all(
              5), // Padding for the inside of the Container
          // GridView for the checkbox grid
          child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 4 / 1, // Adjust as needed for your design
            ),
            itemCount: options.length,
            itemBuilder: (final context, final index) {
              final String key = options.keys.elementAt(index);
              return CheckboxListTile(
                title: Text(key),
                value: options[key],
                onChanged: (final bool? value) {
                  setState(() {
                    options[key] = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity
                    .leading, // Position the checkbox after the text
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 2), // Position the checkbox on the left side
              );
            },
          ),
        ),
      ],
    );
  }
}
