import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../app_localizations.dart';
import 'data.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Map<String, dynamic> cardData = {
    "company": {
      "logo": "assets/logoindex.jpg",
      "address_line1": "Not Loaded",
      "address_line2": "Not Loaded",
      "address_line3": "Not Loaded",
      "phone": ["Not Loaded", "Not Loaded"],
      "email": "Not Loaded",
      "web": "Not Loaded"
    },
    "admin": {
      "name": "Not Loaded",
      "phone": "Not Loaded",
    }
  };

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      Response response = await _dio.get('${Data.baseUrl}/media/data.json');
      if (response.statusCode == 200) {
        setState(() {
          cardData = Map<String, dynamic>.from(response.data['contact']);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('contact_title')),
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Business Card
              Container(
                padding: EdgeInsets.all(16.sp),
                margin: EdgeInsets.symmetric(horizontal: 30.w),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color.fromARGB(255, 55, 99, 174), width: 3.w),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo (Centered)
                    Image.asset(
                      cardData["company"]["logo"],
                      width: 380.w, // Adjust logo size
                      height: 45.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 20.h),

                    // Address
                    Text(
                      "${cardData["company"]["address_line1"]},\n"
                      "${cardData["company"]["address_line2"]},\n"
                      "${cardData["company"]["address_line3"]}",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 12.h),

                    // Phone Numbers
                    Text(
                      cardData["company"]["phone"].join("\n"),
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),

                    // Email & Website
                    Text(
                      "${AppLocalizations.of(context).translate('contact_email')} ${cardData["company"]["email"]}",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    Text(
                      "${AppLocalizations.of(context).translate('contact_web')} ${cardData["company"]["web"]}",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Admin Card
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 40.w),
                padding: EdgeInsets.all(14.sp),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 55, 99, 174),
                  borderRadius: BorderRadius.circular(12.sp),
                ),
                child: Column(
                  children: [
                    Text(
                      cardData["admin"]["name"],
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      cardData["admin"]["phone"],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
