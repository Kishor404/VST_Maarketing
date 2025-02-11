import 'package:flutter/material.dart';

class CompletedServiceDetails extends StatelessWidget {
  final Map<String, dynamic> service;

  const CompletedServiceDetails({Key? key, required this.service})
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
                    Text('Service ID: ${service['service_id']}',
                        style: const TextStyle(
                            fontSize: 18, color: Color.fromARGB(255, 55, 99, 174))),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (service['verified'] == 1)
                          const Text(
                            'Verified',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                        if (service['verified'] == 0)
                          const Text(
                            'Unverified',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic),
                          ),
                      ],
                    ),
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

                /// **Rating Display**
                const Text('Feedback:', style: TextStyle(fontSize: 18)),
                _buildStarRating(service['rating']),
                const SizedBox(height: 16),
                /// **Feedback Box with Fixed Height**
                Container(
                  padding: const EdgeInsets.all(12.0),
                  height: 200,
                  width: double.infinity, // Fixed height for the feedback box
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8.0),
                    // Add border for visibility
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      service['feedback'].isNotEmpty
                          ? service['feedback']
                          : "No feedback provided.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
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

  /// **Star Rating Generator**
  Widget _buildStarRating(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return const Icon(Icons.star, color: Color.fromARGB(255, 55, 99, 174));
        } else if (index < rating) {
          return const Icon(Icons.star_half, color: Color.fromARGB(255, 55, 99, 174));
        } else {
          return const Icon(Icons.star_border, color: Color.fromARGB(255, 55, 99, 174));
        }
      }),
    );
  }
}
