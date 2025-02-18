import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'index.dart';

class EditUserPage extends StatefulWidget {
  @override
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final Dio _dio = Dio();
  String _refreshToken = '';
  String _accessToken = '';
  String _staffid = '';
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String _selectedRegion = 'rajapalayam';
  String _selectedRole = 'customer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshToken = prefs.getString('RT') ?? '';
      _accessToken = prefs.getString('AT') ?? '';
      _staffid = prefs.getString('staff_id') ?? '';
    });
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
      return;
    }

    final url = 'http://127.0.0.1:8000/log/token/refresh/';
    final requestBody = {'refresh': _refreshToken};

    try {
      final response = await _dio.post(
        url,
        data: requestBody,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final newAccessToken = response.data['access'];
      if (newAccessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('AT', newAccessToken);

        setState(() {
          _accessToken = newAccessToken;
        });

        debugPrint("Access token refreshed successfully.");
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
    }
  }

  Future<void> fetchUser() async {
    setState(() => _isLoading = true);
    await _refreshAccessToken();
    try {
      Response response = await _dio.get(
        'http://127.0.0.1:8000/utils/getuserbyid/${_userIdController.text}',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      if (response.statusCode == 200) {
        final userData = response.data;
        setState(() {
          _nameController.text = userData['name'] ?? "";
          _emailController.text = userData['email'] ?? "";
          _phoneController.text = userData['phone'] ?? "";
          _addressController.text = userData['address'] ?? "";
          _cityController.text = userData['city'] ?? "";
          _districtController.text = userData['district'] ?? "";
          _postalCodeController.text = userData['postal_code'] ?? "";
          _countryController.text = userData['country'] ?? "";
          _selectedRegion = userData['region'] ?? "rajapalayam";
          _selectedRole = userData['role'] ?? "customer";
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching user: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> sendReq() async {
    // Show confirmation dialog before sending request
    final bool? confirmed = await _showConfirmationDialog();
    if (confirmed != null && confirmed) {
      setState(() => _isLoading = true);
      try {
        Response response = await _dio.post(
          'http://127.0.0.1:8000/editreq/',
          options: Options(headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          }),
          data: {
            "staff": _staffid,
            "customer": _userIdController.text.toString(),
            "customerData": {
              "name": _nameController.text,
              "email": _emailController.text,
              "phone": _phoneController.text,
              "address": _addressController.text,
              "city": _cityController.text,
              "district": _districtController.text,
              "postal_code": _postalCodeController.text,
              "country": _countryController.text,
              "region": _selectedRegion,
              "role": _selectedRole,
            }
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User updated successfully!")),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => IndexPage()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update user: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Update'),
          content: Text('Are you sure you want to update the user details?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User canceled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit User"), foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 55, 99, 174)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/logoindex.jpg', height: 60),
            SizedBox(height: 20),
            _buildTextField(_userIdController, "Enter User ID"),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 46, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              onPressed: fetchUser,
              child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text("Fetch User"),
            ),
            SizedBox(height: 20),
            _buildUserForm(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 46, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
              onPressed: sendReq,
              child: Text("Send Request"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(255, 55, 99, 174)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildTextField(_nameController, "Name"),
          _buildTextField(_emailController, "Email"),
          _buildTextField(_phoneController, "Phone"),
          _buildTextField(_addressController, "Address"),
          _buildTextField(_cityController, "City"),
          _buildTextField(_districtController, "District"),
          _buildTextField(_postalCodeController, "Postal Code"),
          _buildTextField(_countryController, "Country"),
          SizedBox(height: 10),
          _buildDropdown("Region", _selectedRegion, {
            "rajapalayam": "rajapalayam",
            "ambasamuthiram": "ambasamuthiram",
            "sankarankovil": "sankarankovil",
            "tenkasi": "tenkasi",
            "tirunelveli": "tirunelveli",
            "chennai": "chennai",
          }, (value) => setState(() => _selectedRegion = value!)),
          SizedBox(height: 10),
          _buildDropdown("Role", _selectedRole, {
            "customer": "Customer",
            "worker": "Worker",
            "admin": "Admin",
            "head": "Head",
          }, (value) => setState(() => _selectedRole = value!)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, Map<String, String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.entries
          .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
    );
  }
}
