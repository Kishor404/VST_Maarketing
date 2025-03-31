import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'data.dart';
import '../app_localizations.dart';

class HelpPage extends StatefulWidget {
  @override
  _HelpPageState createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final Dio _dio = Dio();
  List<List<dynamic>> instructions = [];

  @override
  void initState() {
    super.initState();
    fetchInstructions();
  }

  Future<void> fetchInstructions() async {
  try {
    Response response = await _dio.get('${Data.baseUrl}/media/data.json');
    if (response.statusCode == 200) {
      setState(() {
        instructions = (response.data['instructions'] as List)
            .map((section) => [
                  section[0] as String,
                  (section[1] as List<dynamic>).cast<String>() // Ensure steps are List<String>
                ])
            .toList();
      });
    }
  } catch (e) {
    print('Error fetching instructions: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('help_title')),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: instructions.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader until data is fetched
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: instructions.map((section) {
                  return _buildInstructionBox(section[0], section[1]);
                }).toList(),
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
              style: TextStyle(fontSize: 20, color: Color.fromARGB(255, 55, 99, 174)),
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
          Icon(Icons.arrow_right_rounded, color: Color.fromARGB(255, 55, 99, 174)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 77, 77, 77)),
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
