import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceBook extends StatefulWidget {
  const ServiceBook({Key? key}) : super(key: key);

  @override
  ServiceBookState createState() => ServiceBookState();
}

class ServiceBookState extends State<ServiceBook> {
  DateTime? fromDate;
  DateTime? toDate;
  String? selectedComplaint;
  TextEditingController otherComplaintController = TextEditingController();
  TextEditingController complaintDetailsController = TextEditingController();
  String? _customerId;

  final List<String> complaints = ["General Visit", "Water Leakage", "Water Taste Bad", "Others"];

  @override
  void initState() {
    super.initState();
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerId = prefs.getString('customer_id');
    });
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

    Dio dio = Dio();
    const String apiUrl = "http://127.0.0.1:8000/services/";

    Map<String, dynamic> requestBody = {
      "customer": int.parse(_customerId!),
      "staff": 1,
      "available": {
        "from": "${fromDate!.day}/${fromDate!.month}/${fromDate!.year}",
        "to": "${toDate!.day}/${toDate!.month}/${toDate!.year}"
      },
      "description":complaintDescription,
      "complaint": complaintText,
      "status": "BD"
    };

    try {
      Response response = await dio.post(
        apiUrl,
        data: requestBody,
        options: Options(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Service booked successfully!")),
        );
        Navigator.pop(context);
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
                  'http://127.0.0.1:8000/media/utils/Service_Book.jpg',
                  height: 400,
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
