import "package:babylon_app/models/offer.dart";
import "package:cloud_firestore/cloud_firestore.dart";

class OfferService {
  static Future<List<Offer>> getOffers() async {
    final List<Offer> result = List.empty(growable: true);
    try {
      final db = FirebaseFirestore.instance;
      final snapShot = await db.collection("partners").get();

      await Future.forEach(snapShot.docs, (final snapShot) async {
        final partner = snapShot.data();

        result.add(Offer(
            offerUID: snapShot.id,
            name: partner["name"],
            location: partner["location"],
            discount: partner["discount"],
            pictureURL: partner["picture"],
            fullDescription: partner["fullDescription"],
            shortDescription: partner["shortDescription"]));
      });
    } catch (error) {
      rethrow;
    }
    return result;
  }
}
