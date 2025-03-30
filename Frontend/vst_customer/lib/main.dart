import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'pages/index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("🔧 Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    print("📝 Background Notification Title: ${message.notification!.title}");
    print("📝 Background Notification Body: ${message.notification!.body}");

    NotificationService().showNotification(
      title: message.notification!.title ?? "No Title",
      body: message.notification!.body ?? "No Body",
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase Initialized Successfully");
  } catch (e) {
    print("❌ Firebase Initialization Error: $e");
  }

  await NotificationService().initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await requestNotificationPermission();
  await getToken();

  Locale locale = await getSavedLocale();

  runApp(MyApp(locale: locale));
}

// Request notification permission
Future<void> requestNotificationPermission() async {
  try {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("🔔 Notifications authorized");
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print("🔔 Provisional authorization granted");
    } else {
      print("❌ Notifications not authorized");
    }
  } catch (e) {
    print("❌ Error requesting notification permission: $e");
  }
}

// Get and store the FCM token
Future<void> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("✅ FCM Token: $token");
      await prefs.setString('FCM_Token', token);
    } else {
      print("❌ Failed to retrieve FCM token.");
    }
  } catch (e) {
    print("❌ Error fetching FCM token: $e");
  }
}

// Get saved locale
Future<Locale> getSavedLocale() async {
  final prefs = await SharedPreferences.getInstance();
  String? languageCode = prefs.getString('language_code');
  return Locale(languageCode ?? 'en');
}

// Save locale
Future<void> saveLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language_code', locale.languageCode);
}

class MyApp extends StatefulWidget {
  final Locale locale;
  const MyApp({super.key, required this.locale});

  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.locale;
  }

  void changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
    saveLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VST Marketing',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      locale: _locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ta', ''),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      home: const IndexPage(),
    );
  }
}
