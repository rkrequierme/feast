import 'package:flutter/material.dart';
import '../core.dart';

class FeastBottomNavBar extends StatelessWidget {
  /// The index of the currently active item. 
  /// Set to null if you want no items to appear active.
  final int? activeIndex;
  
  /// Callback function when an item is pressed
  final Function(int) onTap;

  const FeastBottomNavBar({
    super.key,
    this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, "Home"),
          _buildNavItem(1, Icons.handshake_outlined, "Requests"),
          _buildNavItem(2, Icons.groups_outlined, "Events"),
          _buildNavItem(3, Icons.chat_bubble_outline_rounded, "Messages"),
          _buildNavItem(4, Icons.settings_outlined, "Settings"),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = activeIndex == index;
    // Using your theme colors: feastDarkGreen for active, feastLightGreen for inactive
    final Color color = isActive ? feastGreen : feastUnselected;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // This container mimics the "filled" house shape in your image
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? feastGreen : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// HOW IT CAN BE USED
/*
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  // 1. Initialize the starting index
  int _currentIndex = 0;

  // 2. Create a list of screens to switch between
  final List<Widget> _screens = [
    const HomeScreen(),
    const RequestsScreen(),
    const EventsScreen(),
    const MessagesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 3. Display the screen based on current index
      body: _screens[_currentIndex],
      
      // 4. Implement your custom Nav Bar
      bottomNavigationBar: FeastBottomNavBar(
        activeIndex: _currentIndex, // Pass the state
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update state on click
          });
        },
      ),
    );
  }
}
*/
