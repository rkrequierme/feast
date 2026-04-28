// lib/core/widgets/feast_toast.dart
//
// Reusable toast notifications for success, error, and info messages.
//
// REACT.JS INTEGRATION NOTE:
// =========================
// In React, use a toast library like react-hot-toast or sonner:
//   import toast from 'react-hot-toast';
//   toast.success('Success message');
//   toast.error('Error message');

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FeastToast {
  static void show(BuildContext context, String message) {
    _showToast(context, message);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, color: feastError);
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, color: feastSuccess);
  }

  static void showInfo(BuildContext context, String message) {
    _showToast(context, message, color: feastBlue);
  }

  static void _showToast(
    BuildContext context,
    String message, {
    Color color = feastGray,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 40,
          right: 40,
        ),
      ),
    );
  }
}
