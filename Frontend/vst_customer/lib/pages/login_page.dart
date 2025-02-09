import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';
import 'package:dio/dio.dart';  // Import Dio

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isLogin = true; // Toggle between login and signup

  final urlDomain="127.0.0.1:8000";

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRegion = 'AUS'; // Default region is 'AUS'

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkSavedLogin();
  }

  // Method to check if login info is saved
  Future<void> _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString('phone');
    final savedPassword = prefs.getString('password');

    if (savedPhone != null && savedPassword != null) {
      // Auto-login with saved info
      _phoneController.text = savedPhone;
      _passwordController.text = savedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isLogin) // Show only during signup
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
            if (!_isLogin)
              SizedBox(height: 10),
            if (!_isLogin) // Region Dropdown with Label
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Region', // Label for the Region dropdown
                  border: OutlineInputBorder(),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRegion,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRegion = newValue!;
                    });
                  },
                  items: <String>['AUS', 'IND', 'USA']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            if (!_isLogin)
              SizedBox(height: 10),
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
              onPressed: () {
                if (_isLogin) {
                  _login();
                } else {
                  _signUp();
                }
              },
              child: Text(_isLogin ? 'Login' : 'Sign Up'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin
                  ? "Don't have an account? Sign Up"
                  : 'Already have an account? Login'),
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
      // Handle login logic with API call
      final url = 'http://$urlDomain/log/customers/login/';
      final requestBody = {'phone': phone, 'password': password};
      
      try {
        // Initialize Dio
        Dio dio = Dio();
        
        // Send POST request with headers
        final response = await dio.post(
          url,
          data: requestBody,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          // Successfully logged in
          final responseData = response.data;

          // Check if the 'login' field is 1 (login successful)
          if (responseData['login'] == 1) {
            // Save login info to SharedPreferences
            final logData = responseData["data"];
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('phone', phone);
            prefs.setString('password', password); 
            prefs.setString('customer_id', logData['id'].toString());
            prefs.setString('name', logData['name'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('email', logData['email'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('address', logData['address'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('city', logData['city'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('state', logData['state'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('country', logData['country'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('postal_code', logData['postal_code'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('region', logData['region'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('AT', responseData['access_token'] ?? 'Unavailable');
            prefs.setString('role', logData['role'] ?? 'Unavailable');
            prefs.setString('RT', responseData['refresh_token'] ?? 'Unavailable'); // Set 'Unavailable' if null
            

            // Navigate to IndexPage after successful login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => IndexPage()),
            );
          } else {
            // Handle login failure based on response
            _showError(responseData['message'] ?? 'Login failed');
          }
        } else {
          // Handle failure (wrong credentials or server error)
          _showError('Login failed. Please check your credentials.');
        }
      } catch (e) {
        // Handle any exceptions (e.g., network issues)
        _showError('An error occurred. Please try again later.');
      }
    } else {
      // Handle case where fields are empty
      _showError('Please fill in all fields');
    }
  }

  Future<void> _signUp() async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final region = _selectedRegion; // Get selected region from dropdown

    if (name.isNotEmpty && phone.isNotEmpty && password.isNotEmpty && region.isNotEmpty) {
      // Perform signup API call
      final url = 'http://$urlDomain/log/customers/signup/'; // Use your correct endpoint
      final requestBody = {
        'name': name,
        'phone': phone,
        'password': password,
        'region': region,
      };
      
      try {
        // Initialize Dio
        Dio dio = Dio();
        
        // Send POST request with headers
        final response = await dio.post(
          url,
          data: requestBody,
          options: Options(
            headers: {
              'Content-Type': 'application/json',
            },
          ),
        );

        if (response.statusCode == 201) {
          // Signup successful
          // final responseData = response.data;
          // print('Response Data: $responseData');

          // Save signup info to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('phone', phone);
          prefs.setString('password', password); 

          // Show a success message (optional)
          _showSuccess('Signup successful! Please log in.');

          // Navigate to LoginPage after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          // Handle signup failure based on response
          _showError('Signup failed. Please try again.');
        }
      } catch (e) {
        // Handle any exceptions (e.g., network issues)
        _showError('An error occurred. Please try again later.');
      }
    } else {
      // Handle case where fields are empty
      _showError('Please fill in all fields');
    }
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
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
