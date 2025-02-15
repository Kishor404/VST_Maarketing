import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  final List<List<dynamic>> instructions = [
    [
      'Getting Started',
      [
        'Open the app and log in with your credentials.',
        'Navigate through the home screen to access features.',
        'Use the menu to explore various sections of the app.',
      ]
    ],
    [
      'Using Features',
      [
        'Tap on an item to get detailed information.',
        'Use search functionality to find specific content.',
        'Bookmark important items for later reference.',
      ]
    ],
    [
      'Troubleshooting',
      [
        'Ensure you have a stable internet connection.',
        'Restart the app if you encounter any issues.',
        'Contact our support team at support@example.com.',
      ]
    ],
    [
      'Troubleshooting',
      [
        'Ensure you have a stable internet connection.',
        'Restart the app if you encounter any issues.',
        'Contact our support team at support@example.com.',
      ]
    ],
    [
      'Troubleshooting',
      [
        'Ensure you have a stable internet connection.',
        'Restart the app if you encounter any issues.',
        'Contact our support team at support@example.com.',
      ]
    ],
    [
      'Troubleshooting',
      [
        'Ensure you have a stable internet connection.',
        'Restart the app if you encounter any issues.',
        'Contact our support team at support@example.com.',
      ]
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help & Instructions'),
        foregroundColor: Color.fromARGB(255, 255, 255, 255),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: instructions.map((section) {
              return _buildInstructionBox(section[0], section[1]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionBox(String title, List<String> steps) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                color: Color.fromARGB(255, 55, 99, 174),
              ),
            ),
            SizedBox(height: 10),
            Column(
              children: steps.map((step) => _buildInstructionStep(step)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right_rounded, color: const Color.fromARGB(255, 55, 99, 174)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 77, 77, 77)),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HelpPage(),
  ));
}
