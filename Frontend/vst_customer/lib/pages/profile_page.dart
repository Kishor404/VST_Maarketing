import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'api.dart';
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
  API api = API();

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

  Future<void> manageChangePassword(oldPass, newPass) async {

    try{
      Map<String, dynamic> response = await api.changePassword(oldPass, newPass);
      if (response["logoit"] == 1) {
        _logout();
      } else if (response["status"] == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password changed successfully"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change password"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }

    
    
  }

  void _showChangePasswordDialog(BuildContext context) {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titlePadding: EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Password',
            style: TextStyle(),
          ),
          SizedBox(height: 16), // Gap between title and content
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85, // 85% of screen width
        height: 100.h, // Custom height
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel',style: TextStyle(color: Colors.black),),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 55, 99, 174),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {
            manageChangePassword(
              currentPasswordController.text,
              newPasswordController.text,
            );
            Navigator.pop(context);
          },
          child: Text('Submit', style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),),
        ),
      ],
    ),
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
                      fontSize: 20.sp, // Responsive text size
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.h), // Responsive height
                  Text(
                    '$_role - $_customerid',
                    style: TextStyle(
                      fontSize: 16.sp, // Responsive text size
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10.h), // Responsive height
                  Text(
                    '+91 $_phone | $_region',
                    style: TextStyle(
                      fontSize: 14.sp, // Responsive text size
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
                        title: Text(_email, style: TextStyle( fontSize: 14.sp)),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on, color: const Color.fromARGB(255, 55, 99, 174)),
                        title: Text(_address,  style: TextStyle( fontSize: 14.sp)),
                      ),
                      Spacer(),
                      ElevatedButton(
                       onPressed: () => _showChangePasswordDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 55, 99, 174),
                          minimumSize: Size(double.infinity, 50.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Change Password',
                          style: TextStyle(fontSize: 16.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10.h),

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
                          style: TextStyle(fontSize: 16.sp, color: Colors.white), // Responsive text size
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
