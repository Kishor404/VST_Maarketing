import 'package:flutter/material.dart';
import 'notification_service.dart'; // Import the notification service
import 'pages/index.dart'; // Import the HomePage from index.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotifications(); // Initialize notifications

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VST Maarketing',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: IndexPage(), // Reference the HomePage
    );
  }
}
