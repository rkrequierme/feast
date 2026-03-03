import 'package:flutter/material.dart';
import 'package:feast/core/core.dart';

class FeastBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FeastBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: feastGreen,
      unselectedItemColor: feastUnselected,
      backgroundColor: feastNavBarBackground,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home_outlined,
            color: feastUnselected,
          ),
          activeIcon: Icon(
            Icons.home,
            color: feastGreen,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.volunteer_activism_outlined,
            color: feastUnselected,
          ),
          activeIcon: Icon(
            Icons.volunteer_activism,
            color: feastGreen,
          ),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.event_outlined,
            color: feastUnselected,
          ),
          activeIcon: Icon(
            Icons.event,
            color: feastGreen,
          ),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.message_outlined,
            color: feastUnselected,
          ),
          activeIcon: Icon(
            Icons.message,
            color: feastGreen,
          ),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings_outlined,
            color: feastUnselected,
          ),
          activeIcon: Icon(
            Icons.settings,
            color: feastGreen,
          ),
          label: 'Settings',
        ),
      ]
    );
  }
}
