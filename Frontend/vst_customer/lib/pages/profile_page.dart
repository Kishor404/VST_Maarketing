import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePage extends StatefulWidget {
  final Function(int) onNavigateToIndex; // Callback to update index in IndexPage

  ProfilePage({super.key, required this.onNavigateToIndex});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String _phone = '';
  String _name = '';
  String _customerid = '';
  String _email = '';
  String _address = '';
  String _region = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadLoginInfo();
  }

  Future<void> _loadLoginInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _phone = prefs.getString('phone') ?? '9087654321';
      _name = prefs.getString('name') ?? 'User Name';
      _customerid = prefs.getString('customer_id') ?? 'User Name';
      _email = prefs.getString('email') ?? 'user@vst.com';
      _region = prefs.getString('region') ?? 'Default Region';
      _role = prefs.getString('role') ?? 'Error';
      _address = "${prefs.getString('address') ?? "00, Unknown"}\n"
          "${prefs.getString('city') ?? "Unavailable"}, ${prefs.getString('district') ?? "Unavailable"}\n"
          "${prefs.getString('postal_code') ?? "000000"}";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    String fcmToken = prefs.getString('FCM_Token') ?? '';
    await prefs.clear();
    prefs.setString('FCM_Token', fcmToken);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 55, 99, 174),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40.r, // Make CircleAvatar responsive
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60.sp, color: Colors.grey),
                  ),
                  SizedBox(height: 10.h), // Responsive height
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 24.sp, // Responsive text size
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.h), // Responsive height
                  Text(
                    '$_role - $_customerid',
                    style: TextStyle(
                      fontSize: 18.sp, // Responsive text size
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10.h), // Responsive height
                  Text(
                    '+91 $_phone | $_region',
                    style: TextStyle(
                      fontSize: 16.sp, // Responsive text size
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.r), // Make border radius responsive
                    topRight: Radius.circular(30.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32.sp), // Responsive padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.email, color: const Color.fromARGB(255, 55, 99, 174)),
                        title: Text(AppLocalizations.of(context).translate('profile_email'), style: TextStyle( fontSize: 16.sp)),
                        subtitle: Text(_email,  style: TextStyle( fontSize: 15.sp)),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on, color: const Color.fromARGB(255, 55, 99, 174)),
                        title: Text(AppLocalizations.of(context).translate('profile_address'),  style: TextStyle( fontSize: 16.sp)),
                        subtitle: Text(_address,  style: TextStyle( fontSize: 15.sp)),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          widget.onNavigateToIndex(1); // Navigate to ServicePage
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                          minimumSize: Size(double.infinity, 50.h), // Responsive size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r), // Make radius responsive
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('profile_service_but'),
                          style: TextStyle(fontSize: 18.sp, color: Colors.white), // Responsive text size
                        ),
                      ),
                      SizedBox(height: 10.h), // Responsive height
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50.h), // Responsive size
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r), // Make radius responsive
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate('profile_logout_but'),
                          style: TextStyle(fontSize: 18.sp, color: Colors.white), // Responsive text size
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
