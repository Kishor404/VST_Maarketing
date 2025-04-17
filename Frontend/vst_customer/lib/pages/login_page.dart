import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'index.dart';
import 'package:dio/dio.dart';
import 'data.dart';
import '../app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  bool _isLogin = true;

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _selectedRegion = 'rajapalayam';
  int langCode = 0;



  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 46),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset('assets/logoindex.jpg', width: 250)),
              SizedBox(height: 40),
              Align(
                alignment: Alignment.center,
                child: Text(
                  _isLogin ? AppLocalizations.of(context).translate('login_title') : AppLocalizations.of(context).translate('signup_title'),
                  style: TextStyle(fontSize: 20),
                ),
              ),
              SizedBox(height: 20),
              if (!_isLogin) ...[
                _buildTextField(_nameController, AppLocalizations.of(context).translate('login_name')),
                SizedBox(height: 10),
                _buildTextField(_emailController, AppLocalizations.of(context).translate('login_email')),
                SizedBox(height: 10),
                _buildDropdownField(),
                SizedBox(height: 10),
                _buildTextField(_addressController, AppLocalizations.of(context).translate('login_address')),
                SizedBox(height: 10),
                _buildTextField(_cityController, AppLocalizations.of(context).translate('login_city')),
                SizedBox(height: 10),
                _buildTextField(_districtController, AppLocalizations.of(context).translate('login_district')),
                SizedBox(height: 10),
                _buildTextField(_postalCodeController, AppLocalizations.of(context).translate('login_postal'), isNumber: true),
                SizedBox(height: 10),
              ],
              _buildTextField(_phoneController, AppLocalizations.of(context).translate('login_phone'), isNumber: true),
              SizedBox(height: 10),
              _buildTextField(_passwordController, AppLocalizations.of(context).translate('login_password'), obscureText: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLogin ? _login : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 64, vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                child: Text(_isLogin ? AppLocalizations.of(context).translate('login_but') : AppLocalizations.of(context).translate('signup_but'), style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin
                    ? AppLocalizations.of(context).translate('login_alt_but')
                    : AppLocalizations.of(context).translate('signup_alt_but'),)
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {bool obscureText = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: const Color.fromARGB(255, 238, 238, 238),
        hintStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: obscureText,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
    );
  }

  Widget _buildDropdownField() {
    return InputDecorator(
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 238, 238, 238),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: _selectedRegion,
        onChanged: (String? newValue) {
          setState(() {
            _selectedRegion = newValue!;
          });
        },
        items: <String>["rajapalayam", "ambasamuthiram", "sankarankovil", "tenkasi", "tirunelveli", "chennai"]
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _signUp() async {
    final name = _nameController.text;
    final phone = _phoneController.text;
    final password = _passwordController.text;
    final email = _emailController.text;
    final address = _addressController.text;
    final city = _cityController.text;
    final district = _districtController.text;
    final postalCode = _postalCodeController.text;
    final region = _selectedRegion;
    final prefs = await SharedPreferences.getInstance();
    final fcm=prefs.getString('FCM_Token');
    print(fcm);

    if (name.isNotEmpty &&
        phone.isNotEmpty &&
        password.isNotEmpty &&
        address.isNotEmpty &&
        city.isNotEmpty &&
        district.isNotEmpty &&
        postalCode.isNotEmpty) {
      final url = '${Data.baseUrl}/log/signup/';
      final requestBody = {
        'name': name,
        'phone': phone,
        'password': password,
        'region': region,
        'email': email.isNotEmpty ? email : null,
        'address': address,
        'city': city,
        'district': district,
        'postal_code': postalCode,
        'role': 'customer',
        'FCM_Token': fcm,
      };

      try {
        Dio dio = Dio();
        final response = await dio.post(
          url,
          data: requestBody,
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 201) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('phone', phone);
          prefs.setString('password', password);
          _showSuccess('Signup successful! Please log in.');
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
        } else {
          _showError('Signup failed. Please try again.');
        }
      } catch (e) {
        _showError('An error occurred. Please try again later.');
        print('==================================> $e');
      }
    } else {
      _showError('Please fill in all required fields.');
    }
  }

  Future<void> _login() async {
     final phone = _phoneController.text;
    final password = _passwordController.text;
    final prefs = await SharedPreferences.getInstance();
    final fcm=prefs.getString('FCM_Token');

    if (phone.isNotEmpty && password.isNotEmpty) {
      // Handle login logic with API call
      final url = '${Data.baseUrl}/log/login/';
      final requestBody = {'phone': phone, 'password': password, "FCM_Token":fcm};
      
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
            prefs.setString('district', logData['district'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('country', logData['country'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('postal_code', logData['postal_code'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('region', logData['region'] ?? 'Unavailable'); // Set 'Unavailable' if null
            prefs.setString('AT', responseData['access_token'] ?? 'Unavailable');
            prefs.setString('role', logData['role'] ?? 'Unavailable');
            prefs.setString('RT', responseData['refresh_token'] ?? 'Unavailable'); // Set 'Unavailable' if null
            

            // Navigate to IndexPage after successful login
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const IndexPage()),
              (Route<dynamic> route) => false, // Remove all previous routes
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

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('OK'))],
      ),
    );
  }
}
