import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'service_page.dart';
import 'products_page.dart';
import 'card_page.dart';
import 'profile_page.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  int _currentIndex = 0; // Keep track of the selected tab

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  // Check if login information is available in SharedPreferences
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone');
    final password = prefs.getString('password');

    if (phone == null || password == null) {
      // If no login info is found, redirect to the LoginPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of pages dynamically
    final List<Widget> pages = [
      HomePage(),
      ServicePage(),
      ProductsPage(),
      CardPage(),
      ProfilePage(
        onNavigateToIndex: (index) {
          setState(() {
            _currentIndex = index; // Update the index on callback
          });
        },
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          flexibleSpace: Center(
            child: Image.asset(
              'assets/logoindex.jpg', // Replace with your logo image path
              height: 60,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
        ),
      ),
      body: pages[_currentIndex], // Display the current page based on selected tab
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 55, 99, 174), // Background color
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color.fromARGB(255, 55, 99, 174), // Set background color
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update selected index on tap
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.construction),
              label: 'Service',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: 'Card',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
