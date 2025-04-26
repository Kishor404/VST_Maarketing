import 'package:flutter/material.dart';
import 'api.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add screenutil import

class ServiceDetails extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ServiceDetails({required this.serviceData, super.key});

  @override
  _ServiceDetailsState createState() => _ServiceDetailsState();
}

class _ServiceDetailsState extends State<ServiceDetails> {
  API api = API();
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
        title: Text(AppLocalizations.of(context).translate('service_details_title')),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // Use ScreenUtil for responsive padding
        child: Card(
          color: const Color.fromRGBO(243, 243, 243, 1),
          elevation: 10,
          margin: EdgeInsets.all(8.w), // Adjust margins responsively
          child: Padding(
            padding: EdgeInsets.all(24.w), // Adjust padding for responsiveness
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('service_details_title'),
                  style: TextStyle(fontSize: 16.sp), // Use ScreenUtil for font size
                ),
                Divider(),
                _buildDetail(AppLocalizations.of(context).translate('service_details_booked_by'), widget.serviceData["customer_data"]?["name"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_card_id'), widget.serviceData["card"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_staff_name'), widget.serviceData["staff_name"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_staff_id'), widget.serviceData["staff"]?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_complaint'), widget.serviceData['complaint']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_description'), widget.serviceData['description']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_date'), widget.serviceData['available_date']?.toString() ?? "None"),
                _buildDetail(AppLocalizations.of(context).translate('service_details_status'), _getStatusLabel(widget.serviceData['status']?.toString() ?? "None")),
                SizedBox(height: 16.h), // Use ScreenUtil for spacing
                Text(AppLocalizations.of(context).translate('service_details_customer_details'), style: TextStyle(fontSize: 16.sp)),
                Divider(),
                _buildCustomerDetails(),
                SizedBox(height: 16.h),
                _buildCancelButton(context, widget.serviceData["id"].toString()),
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
      padding: EdgeInsets.symmetric(vertical: 4.h), // Responsive padding
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
      AppLocalizations.of(context).translate('service_details_customer_city'): widget.serviceData["customer_data"]?["city"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_email'): widget.serviceData["customer_data"]?["email"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_phone'): widget.serviceData["customer_data"]?["phone"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_region'): widget.serviceData["customer_data"]?["region"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_address'): widget.serviceData["customer_data"]?["address"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_district'): widget.serviceData["customer_data"]?["district"]?.toString() ?? "None",
      AppLocalizations.of(context).translate('service_details_customer_postal'): widget.serviceData["customer_data"]?["postal_code"]?.toString() ?? "None",
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
        SizedBox(height: 13.h),
        ElevatedButton(
          onPressed: () => _showCancelDialog(context, serviceId),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r), // Responsive border radius
            ),
          ),
          child: Text(
            AppLocalizations.of(context).translate('service_details_cancel_service'),
            style: TextStyle(fontSize: 12.sp, color: Colors.white),
          ),
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
          title: Text(AppLocalizations.of(context).translate('service_details_cancel_service')),
          content: Text(AppLocalizations.of(context).translate('service_details_cancel_service_text')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).translate('service_details_cancel_service_no')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _onCancelService(serviceId);
              },
              child: Text(AppLocalizations.of(context).translate('service_details_cancel_service_yes'), style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onCancelService(String serviceId) async {
    try {

      Map<String, dynamic> apiData = await api.cancelService(serviceId);
      if (apiData["logout"]==1) {
        _logout();
      }
      bool success = apiData["data"];
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('service_details_cancel_service_success'))),
        );
        Navigator.pop(context); // Close the details page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('service_details_cancel_service_fail'))),
        );
      }
    } catch (e) {
      debugPrint("Error cancelling service: $e");
    }
  }

  Future<void> _logout() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }
}