import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_localizations.dart';
import '../main.dart'; // Import MyApp to update locale

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
        title: Text(AppLocalizations.of(context)!.translate('settings')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('select_language'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            RadioListTile<String>(
              title: const Text("English"),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                _changeLanguage(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text("தமிழ்"),
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
