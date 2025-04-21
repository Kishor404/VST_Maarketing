import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_localizations.dart';

class ServiceLast extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServiceLast({
    required this.serviceData,
    super.key,
  });

  @override
  State<ServiceLast> createState() => _ServiceLastState();
}

class _ServiceLastState extends State<ServiceLast> {
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
        title: Text(AppLocalizations.of(context).translate('service_last_title')),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w), // Responsive padding
        child: Card(
          elevation: 5,
          margin: EdgeInsets.all(8.0.w), // Responsive margin
          child: Padding(
            padding: EdgeInsets.all(32.0.w), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context).translate('service_last_service_details'),
                    style: TextStyle(fontSize: 16.sp)), // Responsive font size
                Divider(),
                _buildDetail(AppLocalizations.of(context).translate('service_last_booked_by'),
                    widget.serviceData["customer_data"]?["name"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_card_id'),
                    widget.serviceData["card"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_staff_name'),
                    widget.serviceData["staff_name"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_staff_id'),
                    widget.serviceData["staff"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_complaint'),
                    widget.serviceData['complaint']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_description'),
                    widget.serviceData['description']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_date'),
                    widget.serviceData['available_date']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_last_status'),
                    _getStatusLabel(widget.serviceData['status']?.toString() ?? "None")),
                SizedBox(height: 32.h), // Responsive spacing
                Text(AppLocalizations.of(context).translate('service_last_customer_details'),
                    style: TextStyle(fontSize: 16.sp)), // Responsive font size
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
      padding: EdgeInsets.symmetric(vertical: 4.0.h), // Responsive padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Color.fromARGB(255, 55, 99, 174), fontSize: 12.sp)), // Responsive font size
          Text(value, style: TextStyle(fontSize: 12.sp)), // Responsive font size
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    Map<String, String> customerData = {
      AppLocalizations.of(context).translate('service_last_customer_city'):
          widget.serviceData["customer_data"]?["city"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_email'):
          widget.serviceData["customer_data"]?["email"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_phone'):
          widget.serviceData["customer_data"]?["phone"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_region'):
          widget.serviceData["customer_data"]?["region"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_address'):
          widget.serviceData["customer_data"]?["address"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_district'):
          widget.serviceData["customer_data"]?["district"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_last_customer_postal'):
          widget.serviceData["customer_data"]?["postal_code"]?.toString() ?? "None",
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: customerData.entries.map((entry) {
        return _buildDetail(entry.key, entry.value);
      }).toList(),
    );
  }
}
