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
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
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
      final url = 'http://$urlDomain/log/customers/login/';
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
            prefs.setString('name', logData['name'] ?? 'Unavailable');
            prefs.setString('email', logData['email'] ?? 'Unavailable');
            prefs.setString('address', logData['address'] ?? 'Unavailable');
            prefs.setString('city', logData['city'] ?? 'Unavailable');
            prefs.setString('state', logData['state'] ?? 'Unavailable');
            prefs.setString('country', logData['country'] ?? 'Unavailable');
            prefs.setString('postal_code', logData['postal_code'] ?? 'Unavailable');
            prefs.setString('region', logData['region'] ?? 'Unavailable');
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
