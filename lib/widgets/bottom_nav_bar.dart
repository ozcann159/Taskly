import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.task),
          label: 'Görevler',
        ),
        NavigationDestination(
          icon: Icon(Icons.analytics),
          label: 'İstatistikler',
        ),
        NavigationDestination(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}