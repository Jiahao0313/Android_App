import "package:babylon_app/models/partner.dart";
import "package:babylon_app/services/partner/partnerService.dart";
import "package:babylon_app/views/navigation_menu.dart";
import "package:flutter/material.dart";

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return const MaterialApp(
      home: FutureBuilderPartners(),
    );
  }
}

class FutureBuilderPartners extends StatefulWidget {
  const FutureBuilderPartners({super.key});

  @override
  State<FutureBuilderPartners> createState() => _FutureBuilderPartnersState();
}

class _FutureBuilderPartnersState extends State<FutureBuilderPartners> {
  final Future<List<Partner>> _partners = PartnerService.getPartners();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
       // Your drawer widget
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text("Partners"),
            SizedBox(
              height: 55,
              width: 55,
              child: Image.asset("assets/images/logowhite.png"), // Your logo asset
            ),
          ],
        ),
        backgroundColor: Colors.green, // Adjust the color as needed
      ),
      body: DefaultTextStyle(
        style: Theme.of(context).textTheme.displayMedium!,
        textAlign: TextAlign.center,
        child: FutureBuilder<List<Partner>>(
          future: _partners, // a previously-obtained Future<String> or null
          builder:
              (final BuildContext context, final AsyncSnapshot<List<Partner>> snapshot) {
            List<Widget> children;
            if (snapshot.hasData) {
              print(1);
              print(snapshot.data);
              children = <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 16, top: 16),
                    child: Text("OUR PARTNERS",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...snapshot.data!.map((final aPartner) =>  
                    Card(
                      child: ListTile(
                        leading: Image.network(aPartner.getPictureURL!),
                        title: Text(aPartner.getName!),
                        subtitle: Text("What you can get: ${aPartner.getDiscount}"),
                        trailing: Icon(Icons.view_list),
                        onTap: () => 
                          showDialog(
                            context: context,
                            builder: (final BuildContext context) {
                              return AlertDialog(
                                title: Text(aPartner.getName!),
                                content: Text("You can get ${aPartner.getDiscount} at ${aPartner.getLocation}"),
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
                          )
                      ),
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
      )
    );
  }
}

class PartnerTile extends StatelessWidget {
  final Partner partner;
  PartnerTile({required this.partner});

  // Function to show details in a pop-up
  void _showDetails(final BuildContext context) {
    showDialog(
      context: context,
      builder: (final BuildContext context) {
        return AlertDialog(
          title: Text(partner.getName!),
          content: Text("You can get ${partner.getDiscount} at ${partner.getLocation}"),
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
        title: Text(partner.getName!),
        subtitle: Text("What you can get: ${partner.getDiscount}"),
        trailing: Icon(Icons.view_list),
        onTap: () => _showDetails(context),
      ),
    );
  }
}
