import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:connect_card/screens/list_of_contacts.dart';
import 'package:connect_card/screens/list_of_visit_card.dart';
import 'package:connect_card/screens/profile_screen.dart';
import 'package:connect_card/screens/register_screen.dart';
import 'package:connect_card/screens/stat_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget{
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen>{
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ListOfContacts(),
    ListOfVisitCard(),
    ProfileScreen(),
    StatScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: Colors.black,
        selectedIndex: _currentIndex,
        showElevation: true,
        itemCornerRadius: 24,
        containerHeight: 50,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, //отсавлять или нет?
        onItemSelected: (index) => setState(() => _currentIndex = index),
        items: [
          _buildNavyBarItem(Icons.home, 'Главная'),
          _buildNavyBarItem(Icons.visibility, 'Визитки'),
          _buildNavyBarItem(Icons.person, 'Профиль'),
          _buildNavyBarItem(Icons.analytics, 'Аналитика'),
        ],
      ),
    );
  }
  BottomNavyBarItem _buildNavyBarItem(IconData icon, String title) {
    return BottomNavyBarItem(
      icon: Icon(icon),
      title: Text(title),
      activeColor: Colors.white,
      inactiveColor: Colors.grey,
      textAlign: TextAlign.center,
    );
  }
}