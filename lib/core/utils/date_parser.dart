import 'package:cloud_firestore/cloud_firestore.dart';

class DateParser {
  /// Safely parses a dynamic Firestore date field into a DateTime.
  /// Handles both Firestore Timestamp objects and ISO 8601 Strings.
  static DateTime? parse(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }
}
