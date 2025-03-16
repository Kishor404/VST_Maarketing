import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart'; // Import the notification service
import 'pages/index.dart'; // Import the HomePage from index.dart
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔧 Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    print("📝 Background Notification Title: ${message.notification!.title}");
    print("📝 Background Notification Body: ${message.notification!.body}");

    // Show local notification using NotificationService
    NotificationService().showNotification(
      title: message.notification!.title ?? "No Title",
      body: message.notification!.body ?? "No Body",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
  }

  await NotificationService().initNotifications(); // Initialize notifications

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Setting up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission for push notifications
  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("🔔 User granted permission: ${settings.authorizationStatus}");
  } catch (e) {
    print("❌ Error requesting notification permission: $e");
  }

  // Get the FCM token
  void getToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print("✅ FCM Token: $token");
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('FCM_Token', token);
      } else {
        print("❌ Failed to retrieve FCM token.");
      }
    } catch (e) {
      print("❌ Error fetching FCM token: $e");
    }
  }

  // Call the token fetching function
  getToken();

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print("📩 Received a foreground message: ${message.messageId}");
    print("🔑 Message data: ${message.data}");
    if (message.notification != null) {
      print("📝 Notification Title: ${message.notification!.title}");
      print("📝 Notification Body: ${message.notification!.body}");

      // Show local notification using NotificationService
      NotificationService().showNotification(
        title: message.notification!.title ?? "No Title",
        body: message.notification!.body ?? "No Body",
      );
    }
  });

  // Listen for message when the app is in the background but not terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🚪 Message clicked: ${message.messageId}");
    if (message.notification != null) {
      print("📝 Clicked Notification Title: ${message.notification!.title}");
      print("📝 Clicked Notification Body: ${message.notification!.body}");
    }
  });

  runApp(const MyApp());
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
      home: const IndexPage(), // Reference the HomePage
    );
  }
}
