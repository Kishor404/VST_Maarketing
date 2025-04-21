import 'package:flutter/material.dart';
import '../app_localizations.dart';
import './login_page.dart';
import './data.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import for screen utils

class WelcomePage extends StatelessWidget {
  final Function(Locale) onLanguageChange;

  const WelcomePage({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B5998), // Blue background
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.sp), // Responsive padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 50.h), // Responsive height
            Text(
              AppLocalizations.of(context).translate('welcome'),
              style: TextStyle(
                fontSize: 24.sp, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h), // Responsive height
            Image.network(
              '${Data.baseUrl}/media/utils/Home_Illus.png',
              height: 250.h, // Responsive image height
            ),
            SizedBox(height: 20.h), // Responsive height
            Text(
              AppLocalizations.of(context).translate('welcome_text'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp, // Responsive font size
                color: Colors.white,
              ),
            ),
            SizedBox(height: 40.h), // Responsive height
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Locale newLocale = Localizations.localeOf(context).languageCode == 'en'
                      ? const Locale('ta')
                      : const Locale('en');
                  onLanguageChange(newLocale);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.sp), // Responsive padding
                ),
                child: Text(
                  Localizations.localeOf(context).languageCode == 'en' ? 'தமிழ்' : 'English',
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF3B5998)),
                ),
              ),
            ),
            SizedBox(height: 20.h), // Responsive height
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.sp), // Responsive padding
                ),
                child: Text(
                  AppLocalizations.of(context).translate('lets_go'),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF3B5998)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
