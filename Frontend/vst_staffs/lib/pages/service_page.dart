import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String lastServiceDate = "DD/MM/YYYY";
  String serviceMan = "Service Man";
  int nextServiceInDays = 0;

  @override
  void initState() {
    super.initState();
    fetchServiceDetails();
  }

  void fetchServiceDetails() {
    // Simulate a backend call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        lastServiceDate = "15/01/2025";
        serviceMan = "John Doe";
        nextServiceInDays = 30;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth*0.8,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    'Last Service: $lastServiceDate',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Last Service By: $serviceMan',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Next Service In: $nextServiceInDays Days',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Image.asset(
                'assets/service_illus.jpg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Add your onPressed code here!
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 20.0),
                textStyle: const TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Book Service', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
