import 'package:flutter/material.dart';
import '../core.dart';

class FeastDrawer extends StatelessWidget {
  final String username;

  const FeastDrawer({
    super.key,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: feastLightGreen,
      child: Column(
        children: [
          // Header Section
          _buildHeader(context),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.notifications_none_outlined, "Notifications", () { Navigator.pushNamed(context, AppRoutes.notifications); }),
                _drawerTile(Icons.bookmark_add_outlined, "Bookmarks", () { Navigator.pushNamed(context, AppRoutes.bookmarks); }),
                _drawerTile(Icons.history_edu_outlined, "Your History", () { Navigator.pushNamed(context, AppRoutes.history); }),
                _drawerTile(Icons.info_outline, "About Us", () { Navigator.pushNamed(context, AppRoutes.about); }),
                _drawerTile(Icons.contact_mail_outlined, "Contact Us", () { Navigator.pushNamed(context, AppRoutes.contact); }),
                _drawerTile(Icons.quiz_outlined, "Help & FAQ", () { Navigator.pushNamed(context, AppRoutes.support); }),
                _drawerTile(Icons.menu_book_outlined, "App Guide", () { Navigator.pushNamed(context, AppRoutes.guide); }),
                _drawerTile(Icons.assignment_outlined, "Terms & Conditions", () { Navigator.pushNamed(context, AppRoutes.legal); }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Header and Background
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: feastLightGreen,
            image: const DecorationImage(
              image: AssetImage('assets/images/Almanza_Dos.jpg'),
              fit: BoxFit.cover,
              opacity: 0.1,
            ),
          ),
          child: Column(
            children: [
              // Close Button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 32, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              // Logo and Branding
              const FeastLogo(height: 80,),
              SizedBox(height: 8),
              const FeastTagline(
                "F.E.A.S.T.",
                fontSize: 24,
                fontFamily: "Ultra",
                strokeColor: feastBlue,
                strokeWidth: 8,
              ),
              SizedBox(height: 8),
              const FeastTagline(
                "Charity Management System",
                fontSize: 16,
                strokeWidth: 8,
              ),
              SizedBox(height: 8),
              FeastLink(
                text: "Current User: $username",
                onPressed: () {
                  
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: feastGreen),
      ],
    );
  }

  Widget _drawerTile(IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black),
          title: Text(
            title,
            style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: "Outfit", fontWeight: FontWeight.w900,),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
          onTap: onTap,
        ),
        const Divider(height: 1, thickness: 1, color: feastGreen),
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
