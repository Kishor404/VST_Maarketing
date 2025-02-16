import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CurrentWork extends StatefulWidget {
  const CurrentWork({super.key});

  @override
  State<CurrentWork> createState() => _CurrentWorkState();
}

class _CurrentWorkState extends State<CurrentWork> {
  String _accessToken = '';
  String _refreshToken = '';
  List<dynamic> services = [];
  Map<String, dynamic>? serviceEntry; // Holds saved service entry
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens();
    await fetchUpcomingWorks();
    await _loadSavedServiceEntry();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('AT') ?? '';
      _refreshToken = prefs.getString('RT') ?? '';
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

  Future<void> fetchUpcomingWorks() async {
    if (_accessToken.isEmpty) return;
    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/utils/currentservice/',
        options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
      );
      setState(() {
        services = response.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> _loadSavedServiceEntry() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedEntry = prefs.getString('serviceEntry');
    if (savedEntry != null) {
      setState(() {
        serviceEntry = json.decode(savedEntry);
      });
    }
  }

Future<void> _showServiceEntryDialog(BuildContext context, Map<String, dynamic> service) async {
  final TextEditingController nextServiceController = TextEditingController();
  final TextEditingController workDetailsController = TextEditingController();
  final TextEditingController partsReplacedController = TextEditingController();
  final TextEditingController icrNumberController = TextEditingController();
  final TextEditingController amountChargedController = TextEditingController();
  
  String visitType = 'C'; // Default value

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Enter Service Details"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nextServiceController,
                  decoration: InputDecoration(labelText: "Next Service Date (YYYY-MM-DD)"),
                ),
                DropdownButtonFormField<String>(
                  value: visitType,
                  items: ['I', 'C', 'MS', 'CS', 'CC']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) {
                    visitType = val!;
                  },
                  decoration: InputDecoration(labelText: "Visit Type"),
                ),
                TextFormField(
                  controller: workDetailsController,
                  decoration: InputDecoration(labelText: "Work Details"),
                ),
                TextFormField(
                  controller: partsReplacedController,
                  decoration: InputDecoration(labelText: "Parts Replaced"),
                ),
                TextFormField(
                  controller: icrNumberController,
                  decoration: InputDecoration(labelText: "ICR Number"),
                ),
                TextFormField(
                  controller: amountChargedController,
                  decoration: InputDecoration(labelText: "Amount Charged"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _createServiceEntry(service, {
                'next_service': nextServiceController.text,
                'visit_type': visitType,
                'work_details': workDetailsController.text,
                'parts_replaced': partsReplacedController.text,
                'icr_number': icrNumberController.text,
                'amount_charged': amountChargedController.text,
              });
            },
            child: Text("Submit"),
          ),
        ],
      );
    },
  );
}


Future<void> _createServiceEntry(Map<String, dynamic> service, Map<String, String> userInput) async {

  await _refreshAccessToken();
  final requestBody = {
    "card": service['card'],
    "date": service['available_date'],
    "next_service": userInput['next_service'],
    "visit_type": userInput['visit_type'],
    "nature_of_complaint": service['complaint'],
    "work_details": userInput['work_details'],
    "parts_replaced": userInput['parts_replaced'],
    "icr_number": userInput['icr_number'],
    "amount_charged": userInput['amount_charged'],
    "customer_signature": {"sign": 0},
    "cse_signature": {"sign": 0}
  };

  try {
    final response = await Dio().post(
      'http://127.0.0.1:8000/api/createserviceentry/',
      data: requestBody,
      options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
    );

    // Save response in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serviceEntry', json.encode(response.data));

    debugPrint("Service entry created successfully.");
  } catch (e) {
    debugPrint("Error creating service entry: $e");
  }
}


  Future<void> _editServiceEntry(BuildContext context) async {
  TextEditingController nextServiceController =
      TextEditingController(text: serviceEntry?['next_service']);
  TextEditingController visitTypeController =
      TextEditingController(text: serviceEntry?['visit_type']);
  TextEditingController workDetailsController =
      TextEditingController(text: serviceEntry?['work_details']);
  TextEditingController partsReplacedController =
      TextEditingController(text: serviceEntry?['parts_replaced']);
  TextEditingController icrNumberController =
      TextEditingController(text: serviceEntry?['icr_number']);
  TextEditingController amountChargedController =
      TextEditingController(text: serviceEntry?['amount_charged'].toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Service Entry"),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7, // 70% of screen width
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nextServiceController,
                  decoration: const InputDecoration(labelText: "Next Service Date"),
                ),
                TextField(
                  controller: visitTypeController,
                  decoration: const InputDecoration(labelText: "Visit Type"),
                ),
                TextField(
                  controller: workDetailsController,
                  decoration: const InputDecoration(labelText: "Work Details"),
                ),
                TextField(
                  controller: partsReplacedController,
                  decoration: const InputDecoration(labelText: "Parts Replaced"),
                ),
                TextField(
                  controller: icrNumberController,
                  decoration: const InputDecoration(labelText: "ICR Number"),
                ),
                TextField(
                  controller: amountChargedController,
                  decoration: const InputDecoration(labelText: "Amount Charged"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final updatedData = {
                "next_service": nextServiceController.text,
                "visit_type": visitTypeController.text,
                "work_details": workDetailsController.text,
                "parts_replaced": partsReplacedController.text,
                "icr_number": icrNumberController.text,
                "amount_charged": amountChargedController.text,
                // Excluded "customer_signature"
              };

              try {
                final response = await _dio.patch(
                  'http://127.0.0.1:8000/api/editserviceentry/${serviceEntry!['id']}/',
                  data: updatedData,
                  options: Options(headers: {'Authorization': 'Bearer $_accessToken'}),
                );

                // Update saved data
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('serviceEntry', json.encode(response.data));

                setState(() {
                  serviceEntry = response.data;
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Service entry updated successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                debugPrint("Error updating service entry: $e");
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Current Service Details",
          style: TextStyle(color: Color.fromARGB(255, 55, 99, 174)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : services.isEmpty
              ? const Center(
                  child: Text(
                    "No Service Available Currently",
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : _buildServiceCard(services.last),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: const BorderSide(color: Color.fromARGB(255, 55, 99, 174), width: 2),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service ID: ${service['id']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              Text('Card ID: ${service['card']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            Text('${service['customer_data']['name']},', style: const TextStyle(fontSize: 18)),
            Text('${service['customer_data']['address']},',
                style: const TextStyle(fontSize: 18)),
            Text('${service['customer_data']['city']},', style: const TextStyle(fontSize: 16)),
            Text('${service['customer_data']['district']}.', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            Text('Phone: ${service['customer_data']['phone']}',
                style: const TextStyle(fontSize: 18)),
            Text('Email: ${service['customer_data']['email']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            Text('Complaint: ${service['complaint']}',
                style: const TextStyle(fontSize: 18)),
            Text('Description: ${service['description']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            Text('Service Date: ${service['available_date']}',
                style: const TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
            Text('Date Of Booking: ${service['created_at'].toString().split('T')[0]}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 36),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 55, 99, 174),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    fixedSize: Size(250, 45),
                  ),
                  onPressed: () {
                    if (serviceEntry == null) {
                      _showServiceEntryDialog(context, service);
                    } else {
                      _editServiceEntry(context);
                    }
                  },
                  child: Text(
                    serviceEntry == null ? "Add Service Entries" : "Edit Service Entries",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
