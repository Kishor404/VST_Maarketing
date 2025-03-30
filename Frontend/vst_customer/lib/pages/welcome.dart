import 'package:flutter/material.dart';
import '../app_localizations.dart';
import './login_page.dart';

class WelcomePage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const WelcomePage({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.translate('welcome'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
                    ? const Locale('ta')
                    : const Locale('en');
                onLanguageChange(newLocale);
              },
              child: Text(
                Localizations.localeOf(context).languageCode == 'en' ? 'தமிழ்' : 'English',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
              },
              child: Text(AppLocalizations.of(context)!.translate('lets_go')),
            ),
          ],
        ),
      ),
    );
  }
}
