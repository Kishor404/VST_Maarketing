import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';
import 'package:dio/dio.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final urlDomain = "127.0.0.1:8000";
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('phone');
    final savedPassword = prefs.getString('password');

    if (savedPhone != null && savedPassword != null) {
      _phoneController.text = savedPhone;
      _passwordController.text = savedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset('assets/logoindex.jpg', width: 250),
            ),
            SizedBox(height: 40),
            Align(
              alignment: Alignment.center,
              child: Text(
                "Login To Your Account",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'Phone Number',
                filled: true,
                fillColor: const Color.fromARGB(255, 238, 238, 238),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none, // Hides the border
                  borderRadius: BorderRadius.circular(10), // Adds rounded corners
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
                filled: true,
                fillColor: const Color.fromARGB(255, 238, 238, 238),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none, // Hides the border
                  borderRadius: BorderRadius.circular(10), // Adds rounded corners
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174), // Button color
                foregroundColor: Colors.white, // Text color
                padding: EdgeInsets.symmetric(horizontal: 64, vertical: 18), // Button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
                elevation: 5, // Shadow effect
              ),
              child: Text('Login',
                style: TextStyle(fontSize: 16), // Text styling
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    final phone = _phoneController.text;
    final password = _passwordController.text;

    if (phone.isNotEmpty && password.isNotEmpty) {
      final url = 'http://$urlDomain/log/login/';
      final requestBody = {'phone': phone, 'password': password};

      try {
        Dio dio = Dio();
        final response = await dio.post(
          url,
          data: requestBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 200) {
          final responseData = response.data;
          print('Response Data: $responseData');

          if (responseData['login'] == 1 && responseData['data']['role'] == 'worker') {
            final logData = responseData["data"];
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('phone', phone);
            prefs.setString('password', password);
            prefs.setString('staff_id', logData['id'].toString());
            prefs.setString('name', logData['name'] ?? 'Unavailable');
            prefs.setString('email', logData['email'] ?? 'Unavailable');
            prefs.setString('address', logData['address'] ?? 'Unavailable');
            prefs.setString('city', logData['city'] ?? 'Unavailable');
            prefs.setString('state', logData['state'] ?? 'Unavailable');
            prefs.setString('country', logData['country'] ?? 'Unavailable');
            prefs.setString('postal_code', logData['postal_code'] ?? 'Unavailable');
            prefs.setString('region', logData['region'] ?? 'Unavailable');
            prefs.setString('role', logData['role'] ?? 'Unavailable');
            prefs.setString('AT', responseData['access_token'] ?? 'Unavailable');
            prefs.setString('RT', responseData['refresh_token'] ?? 'Unavailable');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IndexPage()),
            );
          } else {
            if(responseData['data']['role']!='worker'){
              _showError('Login failed! Only Worker Login');
            }else{
              _showError(responseData['message'] ?? 'Login failed');
            }
          }
        } else {
          _showError('Login failed. Please check your credentials.');
        }
      } catch (e) {
        print('An error occurred: $e');
        _showError('An error occurred. Please try again later.');
      }
    } else {
      _showError('Please fill in all fields');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
