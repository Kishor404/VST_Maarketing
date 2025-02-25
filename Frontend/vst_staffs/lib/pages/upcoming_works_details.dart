import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingServiceDetails extends StatefulWidget {
  final Map<String, dynamic> service;

  const UpcomingServiceDetails({Key? key, required this.service})
      : super(key: key);

  @override
  State<UpcomingServiceDetails> createState() => _UpcomingServiceDetailsState();
}

class _UpcomingServiceDetailsState extends State<UpcomingServiceDetails> {
  String _accessToken = '';
  String _refreshToken = '';
  String _staffid = '';

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _accessToken = prefs.getString('AT') ?? '';
      _refreshToken = prefs.getString('RT') ?? ''; // Refresh token
      _staffid = prefs.getString('staff_id') ?? 'User Name';

    });
  }

  /// **Step 1: Refresh Access Token**
  Future<void> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
      return;
    }

    final url = 'http://127.0.0.1:8000/log/token/refresh/';
    final requestBody = {'refresh': _refreshToken};

    try {
      final response = await Dio().post(
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

  /// **Step 2 & 3: Send Unavailability Request**
  Future<void> _markUnavailable(BuildContext context) async {
    try {
      await _refreshAccessToken(); // Step 1: Refresh token

      // Step 2: Retrieve updated access token
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('AT') ?? '';

      if (accessToken.isEmpty) {
        debugPrint("No access token found!");
        return;
      }

      // Step 3: Make the POST request
      final url = 'http://127.0.0.1:8000/unavailablereq/';
      final requestBody = {
        'service': widget.service['id'], // Ensure 'id' exists
        'staff': _staffid, // Ensure 'staff_id' exists
      };

      final response = await Dio().post(
        url,
        data: requestBody,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Request Sent to Admin Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send request!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred while sending request!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Details"),
        backgroundColor: const Color.fromRGBO(55, 99, 174, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(
                color: Color.fromARGB(255, 55, 99, 174), width: 2),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// **Service ID and Verification Status**
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Service ID: ${widget.service['id']}',
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                  ],
                ),
                Text('Card ID : ${widget.service['card']}',
                    style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 8),

                /// **User Information**
                Text('${widget.service['customer_data']['name']}',
                    style: const TextStyle(fontSize: 18)),
                Text('${widget.service['customer_data']['address']}',
                    style: const TextStyle(fontSize: 18)),
                Text('${widget.service['customer_data']['city']}',
                    style: const TextStyle(fontSize: 16)),
                Text('${widget.service['customer_data']['district']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Contact Details**
                Text('Phone: ${widget.service['customer_data']['phone']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Email: ${widget.service['customer_data']['email']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Service Details**
                Text('Complaint: ${widget.service['complaint']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Description: ${widget.service['description']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                Text('Service Date: ${widget.service['available_date']}',
                    style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                Text('Date Of Booking: ${widget.service['created_at'].toString().split("T")[0]}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 36),

                /// **Unavailable Button with Confirmation**
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Unavailability"),
                            content: const Text(
                                "Are you sure you want to mark this service as unavailable? By Clicking confirm, the request will be sent to admin for confirmation."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop(); // Close dialog
                                  await _markUnavailable(context);
                                },
                                child: const Text("Confirm", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      "Unavailable",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
