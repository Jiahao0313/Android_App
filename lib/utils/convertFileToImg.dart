import "dart:convert";
import "dart:io";
import "dart:typed_data";
import "package:flutter/material.dart";

Future<Image> convertFileToImage({required final File picture}) async {
  final List<int> imageBase64 = picture.readAsBytesSync();
  final String imageAsString = base64Encode(imageBase64);
  final Uint8List uint8list = base64.decode(imageAsString);
  final Image image = Image.memory(uint8list);
  return image;
}
