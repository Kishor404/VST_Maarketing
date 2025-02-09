import 'package:flutter/material.dart';

class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cardData;

  // const CardDetailsPage({Key? key, required this.cardData}) : super(key: key);
  const CardDetailsPage({super.key, required this.cardData});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
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
                for (var service in widget.cardData['service_entries'])
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
                                height:400,
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Service No ${service['id']} Details',style: Theme.of(context).textTheme.headlineMedium),
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
                                    if (service['customer_signature'] != null)
                                      Text('Customer Signature: ${service['customer_signature']['sign']}'),
                                    const SizedBox(height: 6),
                                    if (service['cse_signature'] != null)
                                      Text('CSE Signature: ${service['cse_signature']['sign']}'),
                                    const SizedBox(height: 20),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Close'),
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
