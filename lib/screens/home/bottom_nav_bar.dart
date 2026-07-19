import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int unreadCount;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
        const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Groups'),
        const BottomNavigationBarItem(icon: Icon(Icons.rss_feed), label: 'Channels'),
        const BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Calls'),
        const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}