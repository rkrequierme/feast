import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class FeastBottomNav extends StatelessWidget {
  final int currentIndex; // Pass -1 if you want nothing highlighted
  final Function(int)? onTap; // Now optional

  const FeastBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap, 
  });

  // Centralized navigation handler
  void _handleNavigation(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.aidRequests);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.charityEvents);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.messages);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if we are in a "hidden selection" state
    final bool isUnselected = currentIndex == -1;

    return BottomNavigationBar(
      // If -1, we tell the Bar to highlight index 0, but we'll hide it with colors
      currentIndex: isUnselected ? 0 : currentIndex,
      
      onTap: (index) {
        if (onTap != null) {
          onTap!(index);
        } else {
          _handleNavigation(context, index);
        }
      },

      type: BottomNavigationBarType.fixed,
      backgroundColor: feastNavBarBackground,
      
      // THE TRICK: If unselected, set the active color to match the inactive one
      selectedItemColor: isUnselected ? feastUnselected : feastGreen,
      unselectedItemColor: feastUnselected,

      selectedLabelStyle: TextStyle(
        fontSize: 12,
        fontFamily: "Outfit",
        fontWeight: isUnselected ? FontWeight.w600 : FontWeight.bold,
        // Match the color logic here if the ItemColor property isn't enough
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontFamily: "Outfit",
        fontWeight: FontWeight.w600,
      ),
      
      items: const [
        BottomNavigationBarItem(
          // Note: Removed the hardcoded 'color' from Icons so they
          // obey the selectedItemColor / unselectedItemColor logic!
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.volunteer_activism_outlined),
          activeIcon: Icon(Icons.volunteer_activism),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_outlined),
          activeIcon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          activeIcon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
