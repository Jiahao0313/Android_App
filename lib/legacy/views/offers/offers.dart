import "package:babylon_app/models/offer.dart";
import "package:babylon_app/services/offer/offer_service.dart";
import "package:flutter/material.dart";

class OffersScreen extends StatelessWidget {
  const OffersScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return const MaterialApp(
      home: FutureBuilderOffers(),
    );
  }
}

class FutureBuilderOffers extends StatefulWidget {
  const FutureBuilderOffers({super.key});

  @override
  State<FutureBuilderOffers> createState() => _FutureBuilderOffersState();
}

class _FutureBuilderOffersState extends State<FutureBuilderOffers> {
  final Future<List<Offer>> _partners = OfferService.getOffers();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
        // Your drawer widget
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text("Offers"),
              SizedBox(
                height: 55,
                width: 55,
                child: Image.asset(
                    "assets/images/logowhite.png"), // Your logo asset
              ),
            ],
          ),
          backgroundColor: Colors.green, // Adjust the color as needed
        ),
        body: DefaultTextStyle(
          style: Theme.of(context).textTheme.displayMedium!,
          textAlign: TextAlign.center,
          child: FutureBuilder<List<Offer>>(
            future: _partners, // a previously-obtained Future<String> or null
            builder: (final BuildContext context,
                final AsyncSnapshot<List<Offer>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                children = <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text("Our Partner Offers",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...snapshot.data!.map((final aOffer) => Card(
                        child: ListTile(
                            leading: Image.network(aOffer.pictureURL!),
                            title: Text(aOffer.name),
                            subtitle:
                                Text("What you can get: ${aOffer.discount}"),
                            trailing: Icon(Icons.view_list),
                            onTap: () => showDialog(
                                  context: context,
                                  builder: (final BuildContext context) {
                                    return AlertDialog(
                                      title: Text(aOffer.name),
                                      content: Text(
                                          "You can get ${aOffer.discount} at ${aOffer.location}"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("Close"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                )),
                      ))
                ];
              } else if (snapshot.hasError) {
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text("Error: ${snapshot.error}"),
                  ),
                ];
              } else {
                children = <Widget>[
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                              color: Color(0xFF006400)),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text("Loading..."),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 128),
                        child: Image.asset("assets/images/logoSquare.png",
                            height: 185, width: 185),
                      ),
                    ],
                  )
                ];
              }
              return ListView(
                children: children,
              );
            },
          ),
        ));
  }
}

class OfferTile extends StatelessWidget {
  final Offer partner;
  const OfferTile({super.key, required this.partner});

  // Function to show details in a pop-up
  void _showDetails(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(partner.name),
          content:
              Text("You can get ${partner.discount} at ${partner.location}"),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Card(
      child: ListTile(
        leading: FlutterLogo(size: 56.0), // Replace with actual logo
        title: Text(partner.name),
        subtitle: Text("What you can get: ${partner.discount}"),
        trailing: Icon(Icons.view_list),
        onTap: () => _showDetails(context),
      ),
    );
  }
}
