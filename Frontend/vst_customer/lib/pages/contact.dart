import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  final List<List<String>> contactData = [
    ["Company", "VST Maarketing"],
    ["Admin", "N Udhaya"],
    ["Admin Phone", "9876543210"],
    ["Address", "88, Hox Complex, Tenkasi"],
    ["Phone", "8765432190", "7654321098"],
    ["Email", "vst@gmail.com"],
    ["Web", "www.vst.com"]
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: contactData.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry[0]}:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  for (int i = 1; i < entry.length; i++)
                    Text(
                      entry[i],
                      style: TextStyle(fontSize: 18),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
