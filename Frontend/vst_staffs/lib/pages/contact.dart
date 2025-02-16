import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'data.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Map<String, dynamic> cardData = {
    "company": {
      "logo": "assets/logoindex.jpg",
      "address_line1": "Not Loaded",
      "address_line2": "Not Loaded",
      "address_line3": "Not Loaded",
      "phone": ["Not Loaded", "Not Loaded"],
      "email": "Not Loaded",
      "web": "Not Loaded"
    },
    "admin": {
      "name": "Not Loaded",
      "phone": "Not Loaded",
    }
  };

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      Response response = await _dio.get('${Data.baseUrl}/media/data.json');
      if (response.statusCode == 200) {
        setState(() {
          cardData = Map<String, dynamic>.from(response.data['contact']);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Contact Us'),
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Business Card
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 55, 99, 174), width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo (Centered)
                  Image.asset(
                    cardData["company"]["logo"],
                    width: 380, // Adjust logo size
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  // Address
                  Text(
                    "${cardData["company"]["address_line1"]},\n"
                    "${cardData["company"]["address_line2"]},\n"
                    "${cardData["company"]["address_line3"]}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  // Phone Numbers
                  Text(
                    cardData["company"]["phone"].join("\n"),
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Email & Website
                  Text(
                    "Email: ${cardData["company"]["email"]}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Web: ${cardData["company"]["web"]}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Admin Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    cardData["admin"]["name"],
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    cardData["admin"]["phone"],
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
