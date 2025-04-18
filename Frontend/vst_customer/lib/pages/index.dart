import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'service_page.dart';
import 'products_page.dart';
import 'card_page.dart';
import 'profile_page.dart';
import 'welcome.dart';
import '../main.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  int _currentIndex = 0; // Keep track of the selected tab

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index; // Update BottomNavigationBar index
    });
  }
  
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
        MaterialPageRoute(builder: (context) => WelcomePage( onLanguageChange: (Locale newLocale) {MyApp.setLocale(context, newLocale);},)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the list of pages dynamically
    final List<Widget> pages = [
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => HomePage(onNavigateToIndex: _navigateToPage),
    ),
    ScreenUtilInit(
      designSize: const Size(375, 812), // for example
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const ServicePage(),
    ),
    ScreenUtilInit(
      designSize: const Size(414, 896), // Different design size for Products
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const ProductsPage(),
    ),
    ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const CardPage(),
    ),
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ProfilePage(onNavigateToIndex: _navigateToPage),
    ),
  ];


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
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
              label: AppLocalizations.of(context).translate('nav_home'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.construction),
              label: AppLocalizations.of(context).translate('nav_service'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: AppLocalizations.of(context).translate('nav_products'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: AppLocalizations.of(context).translate('nav_card'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: AppLocalizations.of(context).translate('nav_profile'),
            ),
          ],
        ),
      ),
    );
  }
}
