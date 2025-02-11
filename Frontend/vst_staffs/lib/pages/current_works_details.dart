import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrentWork extends StatefulWidget {
  const CurrentWork({super.key});

  @override
  State<CurrentWork> createState() => _CurrentWorkState();
}

class _CurrentWorkState extends State<CurrentWork> {
  // final Map<String, dynamic> service={
  //     'date':'00/90/1212',
  //     'service_id': '353',
  //     'card_id': '142',
  //     'name': 'Unknown Name',
  //     'address_line1': '00, Street Name',
  //     'city': 'City Name',
  //     'district': 'District Name',
  //     'phone': '+91 0000000000',
  //     'email': 'unknown@gmail.com',
  //     'visit_type': 'Complaint',
  //     'complaint': 'Water Leakage',
  //     'date_of_booking':'09/90/9999',
  //   };

  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> services = [];
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
    await fetchUpcomingWorks();
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
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await _dio.get(
        'http://127.0.0.1:8000/utils/currentservice/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );
      setState(() {
        services = response.data;
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchUpcomingWorks(); // Retry fetching after token refresh
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching services: $e');
    }
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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())  // Show loading indicator
        : services.isEmpty
            ? const Center(
                child: Text(
                  "No Service Available Currently",
                  style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 117, 117, 117)),
                ),
              )
            : _buildServiceCard(services.last), // Show last service
  );
}

Widget _buildServiceCard(Map<String, dynamic> service) {
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: Color.fromARGB(255, 55, 99, 174),
          width: 2,
        ),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service ID: ${service['id']}',
                style: const TextStyle(
                    fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
            const SizedBox(height: 8),

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: Size(250, 45),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Unavailability"),
                        content:
                            const Text("Are you sure you want to update the service card?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Service Card Updated!"),
                                  backgroundColor: Color.fromARGB(255, 55, 99, 174),
                                ),
                              );
                            },
                            child: const Text("Confirm",
                                style: TextStyle(color: Color.fromARGB(255, 55, 99, 174))),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  "Update Service Card",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 55, 99, 174),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  fixedSize: Size(250, 45),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Confirm Unavailability"),
                        content:
                            const Text("Are you sure you want to update the service card?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Service Card Updated!"),
                                  backgroundColor: Color.fromARGB(255, 55, 99, 174),
                                ),
                              );
                            },
                            child: const Text("Confirm",
                                style: TextStyle(color: Color.fromARGB(255, 55, 99, 174))),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  "View Service Card",
                  style: TextStyle(color: Colors.white, fontSize: 18),
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