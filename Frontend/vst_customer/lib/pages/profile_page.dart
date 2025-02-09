import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

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
      _address = "${prefs.getString('address') ?? "00, Unknown"},\n"
          "${prefs.getString('city') ?? "Unavailable"}, ${prefs.getString('state') ?? "Unavailable"}\n"
          "${prefs.getString('postal_code') ?? "000000"}";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _editEmail() {
    TextEditingController emailController = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Email'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Enter new email'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _email = emailController.text;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('email', _email); // Save email to shared preferences
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editAddress() {
    TextEditingController addressController = TextEditingController(text: _address);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Address'),
          content: TextField(
            controller: addressController,
            decoration: InputDecoration(hintText: 'Enter new address'),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                setState(() {
                  _address = addressController.text;
                });
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('address', _address); // Save address to shared preferences
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 55, 99, 174),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 60, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _name,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '$_role - $_customerid',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '+91 $_phone | $_region',
                    style: TextStyle(
                      fontSize: 16,
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
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.email, color: Color.fromARGB(255, 55, 99, 174)),
                        title: Text('Email'),
                        subtitle: Text(_email),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Color.fromARGB(255, 55, 99, 174)),
                          onPressed: _editEmail, // Trigger edit email dialog
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_on, color: Color.fromARGB(255, 55, 99, 174)),
                        title: Text('Address'),
                        subtitle: Text(_address),
                        trailing: IconButton(
                          icon: Icon(Icons.edit, color: Color.fromARGB(255, 55, 99, 174)),
                          onPressed: _editAddress, // Trigger edit address dialog
                        ),
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          widget.onNavigateToIndex(1); // Navigate to ServicePage
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 55, 99, 174),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Service Info',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Log Out',
                          style: TextStyle(fontSize: 18, color: Colors.white),
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
