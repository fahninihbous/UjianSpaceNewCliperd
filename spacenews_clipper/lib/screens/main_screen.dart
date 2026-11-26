import 'package:flutter/material.dart';
import '../theme/space_theme.dart';
import 'explore_screen.dart';
import 'collection_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    ExploreScreen(),
    CollectionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SpaceTheme.borderSubtle, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          backgroundColor: SpaceTheme.surfaceCard,
          selectedItemColor: SpaceTheme.accentAmber,
          unselectedItemColor: SpaceTheme.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Explore'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Koleksi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}