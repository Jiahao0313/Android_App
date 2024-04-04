import "package:babylon_app/models/offer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_storage/firebase_storage.dart";

class OfferService {
  static Future<List<Offer>> getOffers() async {
    final List<Offer> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db.collection("partners").get();

      await Future.forEach(snapShot.docs, (final snapShot) async {
        final partner = snapShot.data();
        final imageUrl = await FirebaseStorage.instance
            .ref()
            .child(partner["picture"])
            .getDownloadURL();
        result.add(Offer(
            documentID: snapShot.id,
            name: partner["name"],
            location: partner["location"],
            discount: partner["discount"],
            pictureURL: imageUrl,
            fullDescription: partner["fullDescription"],
            shortDescription: partner["shortDescription"]));
      });
    } catch (error) {
      rethrow;
    }
    return result;
  }
}
