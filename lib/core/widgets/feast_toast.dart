import 'package:flutter/material.dart';

class FeastToast {
  static void show(BuildContext context, String message) {
    _showToast(context, message);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, color: const Color(0xFFD32F2F));
  }

  // Added this method to fix the error in ForgotPasswordScreen
  static void showSuccess(BuildContext context, String message) {
    _showToast(context, message, color: const Color(0xFF388E3C)); // Green for success
  }

  static void _showToast(BuildContext context, String message, {Color color = const Color(0xFF757A79)}) {
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
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