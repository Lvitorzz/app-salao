// lib/widgets/app_bottom_navigation.dart
import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF732027),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(context, Icons.home, 0),
          _item(context, Icons.bar_chart, 1),
          _item(context, Icons.swap_horiz, 2),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, int index) {
    final selected = index == currentIndex;
    return GestureDetector(
      onTap: () {
        onTap(index);
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/reports');
            break;
          case 2:
            Navigator.pushNamed(context, '/transactions');
            break;
        }
      },
      child: Icon(
        icon,
        size: selected ? 30 : 24,
        color: selected ? Colors.white : Colors.white70,
      ),
    );
  }
}
