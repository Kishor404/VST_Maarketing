import 'package:flutter/material.dart';

class UpcomingServiceDetails extends StatelessWidget {
  final Map<String, dynamic> service;

  const UpcomingServiceDetails({Key? key, required this.service})
      : super(key: key);

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
                    Text('Service ID: ${service['id']}',
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                  ],
                ),
                Text('Card ID : ${service['card']},',
                    style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 8),

                /// **User Information**
                Text('${service['customer_data']['name']},',
                    style: const TextStyle(fontSize: 18)),
                Text('${service['customer_data']['address']},',
                    style: const TextStyle(fontSize: 18)),
                Text('${service['customer_data']['city']},',
                    style: const TextStyle(fontSize: 16)),
                Text('${service['customer_data']['district']}.',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Contact Details**
                Text('Phone: ${service['customer_data']['phone']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Email: ${service['customer_data']['email']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Service Details**
                Text('Complaint: ${service['complaint']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Description: ${service['description']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                Text('Service Date: ${service['available_date']}',
                    style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                Text('Date Of Booking: ${service['created_at'].toString().split("T")[0]}',
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
                            content: const Text("Are you sure you want to mark this service as unavailable? By Clicking confrim the request was send to admin for confrimation."),
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
                                      content: Text("Request Send To Admin !"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
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