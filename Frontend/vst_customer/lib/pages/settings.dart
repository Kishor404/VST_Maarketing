import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../main.dart'; // Import MyApp to update locale
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  // Load the saved language preference
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language_code') ?? 'en';
    });
  }

  // Change language and update locale
  void _changeLanguage(String languageCode) async {
    Locale newLocale = Locale(languageCode);
    await SharedPreferences.getInstance()
        .then((prefs) => prefs.setString('language_code', languageCode));

    MyApp.setLocale(context, newLocale); // Update the app's locale
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('settings')),
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(18.sp), // Responsive padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).translate('select_language'),
              style: TextStyle(
                fontSize: 16.sp, // Responsive font size
              ),
            ),
            SizedBox(height: 10.h), // Responsive height
            RadioListTile<String>(
              title: Text(
                "English",
                style: TextStyle(fontSize: 14.sp), // Responsive font size
              ),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value!);
              },
            ),
            RadioListTile<String>(
              title: Text(
                "தமிழ்",
                style: TextStyle(fontSize: 14.sp), // Responsive font size
              ),
              value: 'ta',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
