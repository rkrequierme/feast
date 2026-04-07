import 'package:flutter/material.dart';
import '../core.dart'; // Ensure feastLightGreen and feastDarkGreen are here

class FeastDrawer extends StatelessWidget {
  final String userName;

  const FeastDrawer({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: feastLightGreen,
      child: Column(
        children: [
          // 1. Header Section
          _buildHeader(context),

          // 2. Navigation Items (List of Tiles)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.notifications_none_outlined, "Notifications", () {}),
                _drawerTile(Icons.bookmark_add_outlined, "Bookmarks", () {}),
                _drawerTile(Icons.history_edu_outlined, "Your History", () {}),
                _drawerTile(Icons.info_outline, "About Us", () {}),
                _drawerTile(Icons.contact_mail_outlined, "Contact Us", () {}),
                _drawerTile(Icons.quiz_outlined, "Help & FAQ", () {}),
                _drawerTile(Icons.menu_book_outlined, "App Guide", () {}),
                _drawerTile(Icons.assignment_outlined, "Terms & Conditions", () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: feastLightGreen.withOpacity(0.8), // Adjust based on background image needs
      ),
      child: Column(
        children: [
          // Close button at top left
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Logo and Branding (Replace with your actual Image.asset)
          const Icon(Icons.eco, size: 60, color: Colors.green), // Placeholder for logo
          const Text(
            "F.E.A.S.T.",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const Text(
            "Charity Management System",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),
          Text(
            "Current User: $userName",
            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
          ),
          const Divider(thickness: 1.5, color: feastGreen),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 18),
          onTap: onTap,
        ),
        const Divider(height: 1, color: feastGreen), // Matching the green lines in your image
      ],
    );
  }
}

// IMPLEMENTATION GUIDE
/*
Scaffold(
  appBar: FeastAppBar(
    title: "Home",
    showBurgerMenu: false, // This will trigger openDrawer() in your earlier code
  ),
  drawer: const FeastDrawer(userName: "Juan De La Cruz"), // Add it here!
  body: YourBodyWidget(),
);
*/
