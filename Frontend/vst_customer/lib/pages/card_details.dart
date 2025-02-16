import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';


class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cardData;

  // const CardDetailsPage({Key? key, required this.cardData}) : super(key: key);
  const CardDetailsPage({super.key, required this.cardData,});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {

  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> products = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens(); 
    await _refreshAccessToken();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshToken = prefs.getString('RT') ?? ''; 
      _accessToken = prefs.getString('AT') ?? ''; 
    });
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
      return;
    }

    final url = '${Data.baseUrl}/log/token/refresh/';
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

  void _showSignConfirmationDialog(BuildContext context, int serviceId) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Confirm Signature"),
        content: const Text("Are you sure you want to sign this service?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signService(serviceId, context);
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

void _signService(int serviceId, BuildContext context) async {
  final dio = Dio();
  final url = '${Data.baseUrl}/api/signbycustomer/$serviceId/';
  final headers = {
    'Content-Type': 'application/json',
    'Authorization':
        'Bearer $_accessToken'
  };
  final data = {
    "customer_signature": {"sign": 1}
  };

  try {
    final response =
        await dio.patch(url, data: data, options: Options(headers: headers));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signed successfully")),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign: ${response.data}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Card'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Details Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Model : ${widget.cardData['model']}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Customer ID : ${widget.cardData['customer_code']}'),
                      const SizedBox(height: 8),
                      Text('Date Of Installation : ${widget.cardData['date_of_installation']}'),
                      const SizedBox(height: 8),
                      Text('Customer Name : ${widget.cardData['customer_name']}'),
                      const SizedBox(height: 8),
                      Text('Customer Region : ${widget.cardData['region']}'),
                      const SizedBox(height: 16),
                      Text(
                        'Period : ${widget.cardData['warranty_start_date']} - ${widget.cardData['warranty_end_date']}',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 55, 99, 174),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Services List
              if (widget.cardData['service_entries'] != null &&
                  widget.cardData['service_entries'] is List)
                for (var service in widget.cardData['service_entries'].reversed)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 30.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                width: 400, // Set the width of the dialog here
                                height: 600,
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service No ${service['id']} Details',
                                        style: Theme.of(context).textTheme.headlineMedium),
                                    const SizedBox(height: 16),
                                    Text('Date: ${service['date']}'),
                                    const SizedBox(height: 6),
                                    Text('Visit Type: ${service['visit_type']}'),
                                    const SizedBox(height: 6),
                                    Text('Nature of Complaint: ${service['nature_of_complaint']}'),
                                    const SizedBox(height: 6),
                                    Text('Work Details: ${service['work_details']}'),
                                    const SizedBox(height: 6),
                                    Text('Parts Replaced: ${service['parts_replaced']}'),
                                    const SizedBox(height: 6),
                                    Text('ICR Number: ${service['icr_number']}'),
                                    const SizedBox(height: 6),
                                    Text('Amount Charged: ${service['amount_charged']}'),
                                    const SizedBox(height: 16),

                                    // Customer & CSE Signatures (if applicable)
                                    if (service['customer_signature'] != null &&
                                        service['customer_signature']['sign'] != 0)
                                      Text('Customer Signature: Verified',style: TextStyle(color: Colors.green),),
                                    
                                    if (service['customer_signature'] != null &&
                                        service['customer_signature']['sign'] != 0)
                                      TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),

                                    if (service['customer_signature'] == null ||
                                      service['customer_signature']['sign'] == 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () =>
                                              _showSignConfirmationDialog(context, service['id']),
                                          child: const Text('Sign'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },


                      child: Text('Service No ${service['id']} - ${service['date']}'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
