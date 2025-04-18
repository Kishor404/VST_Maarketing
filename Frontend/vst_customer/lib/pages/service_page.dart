import 'package:flutter/material.dart';
import 'package:vst_maarketing/pages/service_last.dart';
import 'service_details.dart';
import 'service_book.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import screenutil

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});
  @override
  ServicePageState createState() => ServicePageState();
}

class ServicePageState extends State<ServicePage> {
  String lastServiceDate = "No Service Data";
  String nextService = "No Service Data";
  String nextServiceCard = "No Service Data";

  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> services = [];
  List<dynamic> bookedServices = [];
  List<dynamic> cancelServices = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  bool bookButton = true;
  bool lastButton = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens();
    await _refreshAccessToken();
    await fetchNextService();
    await fetchServices();
    fetchServiceDetails(); // No need for `await` as it's not an API call
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _refreshToken = prefs.getString('RT') ?? '';
      _accessToken = prefs.getString('AT') ?? '';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _refreshAccessToken() async {
  if (_refreshToken.isEmpty) {
    debugPrint("No refresh token found! Logging out...");
    await _logout();
    return;
  }

  final url = '${Data.baseUrl}/log/token/refresh/';
  final requestBody = {'refresh': _refreshToken};

  try {
    final response = await _dio.post(
      url,
      data: requestBody,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode == 200 && response.data['access'] != null) {
      final newAccessToken = response.data['access'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('AT', newAccessToken);

      setState(() {
        _accessToken = newAccessToken;
      });

      debugPrint("Access token refreshed successfully.");
    } else {
      debugPrint("Invalid refresh token. Logging out...");
      await _logout();
    }
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 401) {
      debugPrint("Refresh token expired. Logging out...");
      await _logout();
    } else {
      debugPrint("Error refreshing token: $e");
    }
  }
}


  Future<void> fetchServices() async {
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/services/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      setState(() {
        services = response.data;
      });

      fetchServiceDetails(); // Process fetched services
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchServices();
      }

      debugPrint('Error fetching services: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchNextService() async {
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/utils/next-service/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      setState(() {
        nextService = response.data["days_remaining"].toString();
        nextServiceCard = response.data["card_id"].toString();
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchNextService();
      }
      debugPrint('Error fetching next service: $e');
    }
  }

  void fetchServiceDetails() {
    if (services.isEmpty) return;

    List<dynamic> tempBookedServices = [];
    List<dynamic> tempCancelServices = [];
    String tempLastServiceDate = lastServiceDate;

    for (var service in services) {
      switch (service["status"]) {
        case "SD":
          tempLastServiceDate = service["date_of_service"];
          break;
        case "BD":
        case "SP":
          tempBookedServices.add(service);
          break;
        case "NS":
        case "CC":
        case "CW":
          tempCancelServices.add(service);
          break;
      }
    }

    setState(() {
      lastServiceDate = tempLastServiceDate;
      bookedServices = tempBookedServices;
      cancelServices = tempCancelServices;
      bookButton = bookedServices.isEmpty;
      lastButton = cancelServices.isNotEmpty;
    });
  }

  Widget buildServiceButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
        textStyle: TextStyle(fontSize: 18.sp),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 10.h, bottom: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.8,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 30.h),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  Text(
                    AppLocalizations.of(context).translate('service_title'),
                    style: TextStyle(fontSize: 22.sp, color: Colors.white),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    '${AppLocalizations.of(context).translate('service_last_service')} $lastServiceDate',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate('service_next_service')} $nextServiceCard',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate('service_next_service_in')} $nextService ${AppLocalizations.of(context).translate('service_next_service_days')}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Image.network('${Data.baseUrl}/media/utils/Service_Illus.jpg', height: 400.h),
            ),
            SizedBox(height: 10.h),

            lastButton
                ? buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_cancelled_service'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceLast(serviceData: cancelServices.last))),
                  )
                : Container(),

            SizedBox(height: 15.h),

            bookButton
                ? buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_book_service'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceBook())),
                  )
                : buildServiceButton(
                    label: AppLocalizations.of(context).translate('service_details'),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetails(serviceData: bookedServices.last))),
                  ),
          ],
        ),
      ),
    );
  }
}
