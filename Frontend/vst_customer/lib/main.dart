import 'package:flutter/material.dart';
import 'pages/index.dart'; // Import the HomePage from home.dart

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VST Maarketing',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins'
      ),
      home: IndexPage(), // Reference the HomePage
    );
  }
}
