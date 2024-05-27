import "dart:io";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";

class EventException {
  static void validateUpdateOrCreateForm(
      {required final String eventName,
      final File? image,
      required final DateTime? selectedDateTime,
      required final TimeOfDay? selectedTimeOfDay,
      final String? shortDescription,
      final String? description,
      required final String place}) {
    if (eventName == "") {
      throw ("The title is missing");
    }
    if (selectedDateTime == null) {
      throw ("The date is missing");
    }
    if (selectedTimeOfDay == null) {
      throw ("The date is missing");
    }
    try {
      Timestamp.fromDate(DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          selectedTimeOfDay.hour,
          selectedTimeOfDay.minute));
    } catch (e) {
      throw ("The date is missing");
    }
    if (place == "") {
      throw ("The location is missing");
    }
  }
}
