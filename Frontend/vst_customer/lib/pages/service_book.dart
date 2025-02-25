import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import '../notification_service.dart';
import 'index.dart';

class ServiceBook extends StatefulWidget {
  const ServiceBook({super.key});


  @override
  ServiceBookState createState() => ServiceBookState();
}

class ServiceBookState extends State<ServiceBook> {
  String _refreshToken = '';
  String _accessToken = '';
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedComplaint;
  TextEditingController otherComplaintController = TextEditingController();
  TextEditingController complaintDetailsController = TextEditingController();
  String? _customerId;
  List<Map<String, dynamic>> cardData = [];
  final Dio _dio = Dio();
  String? selectedCard;


  List<String> complaints = ["General Visit","Others"];

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens(); 
    await _refreshAccessToken();
    await fetchData();
    await fetchCards(); 
  }

  Future<void> fetchData() async {
    try {
      Response response = await _dio.get('${Data.baseUrl}/media/data.json');
      if (response.statusCode == 200) {
        setState(() {
          complaints = List<String>.from(response.data['complaints'] ?? ["General Visit","Others"]);
        });
      }
    } catch (e) {
      print('Error fetching complaints: $e');
    }
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshToken = prefs.getString('RT') ?? ''; 
      _accessToken = prefs.getString('AT') ?? ''; 
    });
  }


  Future<void> _loadCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerId = prefs.getString('customer_id');
    });
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
      return;
    }

    final url =  "${Data.baseUrl}/log/token/refresh/";
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

  Future<void> fetchCards() async {
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch cards.");
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/api/cards-details/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          cardData = List<Map<String, dynamic>>.from(response.data);

        });
      } else {
        debugPrint("Unexpected response format: ${response.data}");
        setState(() {

        });
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchCards(); // Retry fetching after token refresh
      }

      setState(() {
      });
      debugPrint('Error fetching cards: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2100);

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  Future<void> _bookService() async {
  if (fromDate == null || toDate == null || selectedComplaint == null || _customerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  String complaintText = selectedComplaint == "Others"
      ? otherComplaintController.text
      : selectedComplaint ?? "";

  String complaintDescription = complaintDetailsController.text;

  final String checkAvailabilityUrl = "${Data.baseUrl}/utils/checkstaffavailability/";

  Map<String, dynamic> availabilityRequestBody = {
    "from_date": "${fromDate!.year}-${fromDate!.month}-${fromDate!.day}",
    "to_date": "${toDate!.year}-${toDate!.month}-${toDate!.day}"
  };
  try {
    Response availabilityResponse = await _dio.post(
      checkAvailabilityUrl,
      data: availabilityRequestBody,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $_accessToken',
        },
      ),
    );

    if (availabilityResponse.data.containsKey("worker_id")) {
      int workerId = availabilityResponse.data["worker_id"];
      String avaDate = availabilityResponse.data["available"];
      // Proceed with booking since a worker is available
      await _confirmBooking(workerId, avaDate, complaintText, complaintDescription);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No workers available during this period")),
      );
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error checking staff availability: $e")),
    );
  }
}

Future<void> _confirmBooking(int workerId, String avaDate, String complaintText, String complaintDescription) async {
  final String apiUrl = "${Data.baseUrl}/services/";
  int cardId = int.parse(selectedCard!.split('-')[0]);

  Map<String, dynamic> requestBody = {
    "customer": int.parse(_customerId!),
    "staff": workerId, // Assign the available worker
    "staff_name": "Assigned Worker", // Modify based on API response
    "available": {
      "from": "${fromDate!.year}/${fromDate!.month}/${fromDate!.day}",
      "to": "${toDate!.year}/${toDate!.month}/${toDate!.day}"
    },
    "available_date":avaDate,
    "description": complaintDescription,
    "complaint": complaintText,
    "status": "BD",
    "card": cardId,
  };

  try {
    Response response = await _dio.post(
      apiUrl,
      data: requestBody,
      options: Options(
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $_accessToken',
        },
      ),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Service booked successfully!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => IndexPage()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
      NotificationService().showNotification(
          id: 0,
          title: "Service Booked !",
          body: "The Service Booking was sucessfull",
        );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book service")),
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
        title: const Text(
          "Service Booking",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: 70,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.network(
                   "${Data.baseUrl}media/utils/Service_Book.jpg",
                  height: 250,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Available Period",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: fromDate == null
                                ? "From"
                                : "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: toDate == null
                                ? "To"
                                : "${toDate!.day}/${toDate!.month}/${toDate!.year}",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Your Card",
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Card",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: selectedCard,
                items: cardData.map((card) {
                  String displayText = "${card['id']}-${card['model']}";
                  return DropdownMenuItem<String>(
                    value: displayText,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCard = newValue;
                  });
                },
              ),
              const SizedBox(height: 30),
              const Text(
                "Service Details",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              

              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: "Type of Complaint",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                value: selectedComplaint,
                items: complaints.map((String complaint) {
                  return DropdownMenuItem<String>(
                    value: complaint,
                    child: Text(complaint),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedComplaint = newValue;
                  });
                },
              ),
              if (selectedComplaint == "Others") ...[
                const SizedBox(height: 10),
                TextField(
                  controller: otherComplaintController,
                  decoration: InputDecoration(
                    labelText: "Enter your complaint",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
              if (selectedComplaint != null && selectedComplaint != "General Visit") ...[
                const SizedBox(height: 10),
                TextField(
                  controller: complaintDetailsController,
                  decoration: InputDecoration(
                    labelText: "Briefly describe your complaint",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _bookService,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(fontSize: 18, color: Colors.white),
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
