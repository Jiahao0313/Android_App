class Offer {
  // Attributes

  String offerUID;
  String name;
  String? location;
  String? discount;
  String? pictureURL;
  String? fullDescription;
  String? shortDescription;

  // Constructors

  Offer(
      {required this.offerUID,
      required this.name,
      this.location,
      this.discount,
      this.pictureURL,
      this.fullDescription,
      this.shortDescription});
}
