import 'package:flutter/material.dart';

class ServiceLast extends StatelessWidget {
  final Map<String, dynamic> serviceData;

  const ServiceLast({
    required this.serviceData,
    super.key,
  });

  // Map for status choices
  static const Map<String, String> STATUS_CHOICES = {
    'BD': 'Booked',
    'SD': 'Serviced',
    'NS': 'Not Serviced',
    'CC': 'Cancelled',
    'CW': 'Service Cancelled By Worker',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cancelled Service Details'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to get the status label from the map
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
      children: customerData.entries
          .map((entry) => _buildDetail(entry.key, entry.value))
          .toList(),
    );
  }


}