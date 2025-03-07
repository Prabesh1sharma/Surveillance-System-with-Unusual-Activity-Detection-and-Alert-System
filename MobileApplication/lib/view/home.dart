import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:majorapp/view/add.dart';
import 'notification_page.dart';
import 'storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  final List<Widget> _pages = [NotificationPage(), AddPage(), StoragePage()];

  void _navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4, // Adds a shadow for depth
        title: const Text(
          'All Eyes On You',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Pacifico', // Use a stylish font (add in pubspec.yaml)
            letterSpacing: 1.2, // Slight spacing for better readability
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFC690CE), Color(0xFF8E44AD)], // Gradient effect
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromRGBO(198, 160, 206, 0.2),
        color: const Color.fromRGBO(198, 160, 206, 1),
        buttonBackgroundColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex, // Ensure it reflects the selected page
        items: const [
          Icon(Icons.notifications, size: 30, color: Colors.black),
          Icon(Icons.home, size: 30, color: Colors.black),
          Icon(Icons.storage, size: 30, color: Colors.black),
        ],
        onTap: _navigateToPage, // Directly update the state
      ),
    );
  }
}
