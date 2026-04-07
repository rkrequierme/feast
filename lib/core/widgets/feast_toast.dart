import 'package:flutter/material.dart';
import '../core.dart'; // Assuming feastGrey and AppTextStyles are here

class FeastToast {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Makes the snackbar float so we can apply border radius
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent, 
        elevation: 0,
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF757A79), // The specific grey from your image
            borderRadius: BorderRadius.circular(100), // Fully rounded pill shape
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat', // Or your specific app font
            ),
          ),
        ),
        duration: const Duration(seconds: 2),
        // Adjust margin to position it where you want on screen
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: 40,
          right: 40,
        ),
      ),
    );
  }
}

// HOW TO USE
/*
ElevatedButton(
  onPressed: () {
    // Calling your reusable toast
    FeastToast.show(context, "Saved To Bookmarks.");
  },
  child: const Text("Save Item"),
)
*/
