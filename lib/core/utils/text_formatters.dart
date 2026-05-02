// lib/core/utils/text_formatters.dart
//
// Reusable text input formatters for consistent text input behavior across the app.

import 'package:flutter/services.dart';

/// Forces all input characters to lowercase.
/// Useful for email fields to prevent case-sensitive login issues.
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [LowerCaseTextFormatter()],
/// )
/// ```
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toLowerCase());
  }
}

/// Capitalizes the first letter of each word.
/// Useful for name fields (First Name, Last Name).
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [CapitalizeWordsFormatter()],
/// )
/// ```
class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    
    final words = newValue.text.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return word;
      if (word.length == 1) return word.toUpperCase();
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return newValue.copyWith(text: capitalized);
  }
}

/// Limits input to numbers only.
/// Useful for numeric fields like age, quantity, etc.
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [NumbersOnlyFormatter()],
/// )
/// ```
class NumbersOnlyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filtered = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    return newValue.copyWith(text: filtered);
  }
}

/// Formats phone numbers for the Philippines.
/// Converts +63XXXXXXXXXX to +63 XXX XXX XXXX format.
///
/// Usage:
/// ```dart
/// TextFormField(
///   inputFormatters: [PhilippinePhoneFormatter()],
/// )
/// ```
class PhilippinePhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = newValue.text.replaceAll(RegExp(r'\D'), '');
    
    if (cleaned.isEmpty) return newValue.copyWith(text: '');
    
    // Format as +63 XXX XXX XXXX
    if (cleaned.length >= 2 && cleaned.startsWith('63')) {
      final withoutPrefix = cleaned.substring(2);
      if (withoutPrefix.isEmpty) return newValue.copyWith(text: '+63');
      
      String formatted = '+63';
      if (withoutPrefix.length >= 3) {
        formatted += ' ${withoutPrefix.substring(0, 3)}';
      } else {
        formatted += ' $withoutPrefix';
        return newValue.copyWith(text: formatted);
      }
      
      if (withoutPrefix.length >= 6) {
        formatted += ' ${withoutPrefix.substring(3, 6)}';
      } else if (withoutPrefix.length > 3) {
        formatted += ' ${withoutPrefix.substring(3)}';
        return newValue.copyWith(text: formatted);
      }
      
      if (withoutPrefix.length >= 10) {
        formatted += ' ${withoutPrefix.substring(6, 10)}';
      } else if (withoutPrefix.length > 6) {
        formatted += ' ${withoutPrefix.substring(6)}';
      }
      
      return newValue.copyWith(text: formatted);
    }
    
    return newValue;
  }
}
