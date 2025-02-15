import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceDetails extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetails({
    required this.serviceData,
    super.key,
  });

  static const Map<String, String> STATUS_CHOICES = {
    'BD': 'Booked',
    'SD': 'Serviced',
    'NS': 'Not Serviced',
    'CC': 'Service Cancelled By Customer',
    'CW': 'Service Cancelled By Worker',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Service Details', style: TextStyle(fontSize: 20)),
                Divider(),
                _buildDetail('Booked By', serviceData["customer_data"]?["name"]?.toString() ?? "None"),
                _buildDetail('Card ID', serviceData["card"]?.toString() ?? "None"),
                _buildDetail('Staff Name', serviceData["staff_name"]?.toString() ?? "None"),
                _buildDetail('Staff ID', serviceData["staff"]?.toString() ?? "None"),
                _buildDetail('Complaint', serviceData['complaint']?.toString() ?? "None"),
                _buildDetail('Description', serviceData['description']?.toString() ?? "None"),
                _buildDetail('Appointed Date', serviceData['available_date']?.toString() ?? "None"),
                _buildDetail('Status', _getStatusLabel(serviceData['status']?.toString() ?? "None")),
                SizedBox(height: 32),
                Text('Customer Data:', style: TextStyle(fontSize: 18)),
                Divider(),
                _buildCustomerDetails(),
                SizedBox(height: 32),
                _buildCancelButton(context, serviceData["id"].toString()), // Pass service ID
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(String statusCode) {
    return STATUS_CHOICES[statusCode] ?? "Unknown Status";
  }

  Widget _buildDetail(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Color.fromARGB(255, 55, 99, 174), fontSize: 17)),
          Text(value, style: TextStyle(fontSize: 17)),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    Map<String, String> customerData = {
      "City": serviceData["customer_data"]?["city"]?.toString() ?? "None",
      "Name": serviceData["customer_data"]?["name"]?.toString() ?? "None",
      "Email": serviceData["customer_data"]?["email"]?.toString() ?? "None",
      "Phone": serviceData["customer_data"]?["phone"]?.toString() ?? "None",
      "Region": serviceData["customer_data"]?["region"]?.toString() ?? "None",
      "Address": serviceData["customer_data"]?["address"]?.toString() ?? "None",
      "District": serviceData["customer_data"]?["district"]?.toString() ?? "None",
      "Postal Code": serviceData["customer_data"]?["postal_code"]?.toString() ?? "None",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: customerData.entries.map((entry) {
        return _buildDetail(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildCancelButton(BuildContext context, String serviceId) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () => _showCancelDialog(context, serviceId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
            child: Text('Cancel Service', style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Cancel Service"),
          content: Text("Are you sure you want to cancel this service?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onCancelService(context, serviceId);
              },
              child: Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onCancelService(BuildContext context, String serviceId) async {
    try {
      // Step 1: Refresh Access Token
      String? newAccessToken = await _refreshAccessToken();
      if (newAccessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to refresh access token.")),
        );
        return;
      }

      // Step 2: Send API Request to Cancel Service
      bool success = await _cancelService(newAccessToken, serviceId);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Service cancelled successfully!")),
        );
        Navigator.pop(context); // Close the details page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel service!")),
        );
      }
    } catch (e) {
      debugPrint("Error cancelling service: $e");
    }
  }

  Future<String?> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString('RT') ?? '';

    if (refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
      return null;
    }

    final String url = 'http://127.0.0.1:8000/log/token/refresh/';
    final Dio dio = Dio();

    try {
      final response = await dio.post(
        url,
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final String newAccessToken = response.data['access'];
      await prefs.setString('AT', newAccessToken);
      debugPrint("Access token refreshed successfully.");

      return newAccessToken;
    } catch (e) {
      debugPrint("Error refreshing token: $e");
      return null;
    }
  }

  Future<bool> _cancelService(String accessToken, String serviceId) async {
    final String url = 'http://127.0.0.1:8000/services/cancleservicebycustomer/$serviceId';
    final Dio dio = Dio();

    try {
      final response = await dio.patch(
        url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Service cancelled successfully.");
        return true;
      } else {
        debugPrint("Failed to cancel service. Status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("Error cancelling service: $e");
      return false;
    }
  }
}
