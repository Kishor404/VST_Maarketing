import 'package:flutter/material.dart';

class CurrentWorksDetails extends StatelessWidget {
  final Map<String, dynamic> service={
      'date':'00/90/1212',
      'service_id': '353',
      'card_id': '142',
      'name': 'Unknown Name',
      'address_line1': '00, Street Name',
      'city': 'City Name',
      'district': 'District Name',
      'phone': '+91 0000000000',
      'email': 'unknown@gmail.com',
      'visit_type': 'Complaint',
      'complaint': 'Water Leakage',
      'date_of_booking':'09/90/9999',
    };

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
                    Text('Service ID: ${service['service_id']}',
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                  ],
                ),
                const SizedBox(height: 8),

                /// **Card ID**
                Text('Card ID: ${service['card_id']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **User Information**
                Text('${service['name']},',
                    style: const TextStyle(fontSize: 18)),
                Text('${service['address_line1']},',
                    style: const TextStyle(fontSize: 18)),
                Text('${service['city']},',
                    style: const TextStyle(fontSize: 16)),
                Text('${service['district']}.',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Contact Details**
                Text('Phone: ${service['phone']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Email: ${service['email']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                /// **Service Details**
                Text('Visit Type: ${service['visit_type']}',
                    style: const TextStyle(fontSize: 18)),
                Text('Complaint: ${service['complaint']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),

                Text('Service Date: ${service['date']}',
                    style: const TextStyle(fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                Text('Date Of Booking: ${service['date_of_booking']}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 36),

                /// **Unavailable Button with Confirmation**
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
                            content: const Text("Are you sure you want Update the service card?"),
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
                                      content: Text("Service Card Update !"),
                                      backgroundColor: Color.fromARGB(255, 55, 99, 174),
                                    ),
                                  );
                                },
                                child: const Text("Confirm", style: TextStyle(color: Color.fromARGB(255, 55, 99, 174))),
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

                /// **Unavailable Button with Confirmation**
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
                            content: const Text("Are you sure you want View the service card?"),
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
                                      content: Text("Service Card View !"),
                                      backgroundColor: Color.fromARGB(255, 55, 99, 174),
                                    ),
                                  );
                                },
                                child: const Text("Confirm", style: TextStyle(color: Color.fromARGB(255, 55, 99, 174))),
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
      ),
    );
  }
}