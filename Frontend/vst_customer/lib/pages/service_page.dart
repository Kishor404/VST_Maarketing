import 'package:flutter/material.dart';
import 'package:vst_maarketing/pages/service_last.dart';
import 'service_details.dart';
import 'service_book.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';

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

  Future<void> _refreshAccessToken() async {
    if (_refreshToken.isEmpty) {
      debugPrint("No refresh token found!");
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

      final newAccessToken = response.data['access'];
      if (newAccessToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('AT', newAccessToken);

        setState(() {
          _accessToken = newAccessToken;
        });

        debugPrint("Access token refreshed successfully.");
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
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
        padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 20.0),
        textStyle: const TextStyle(fontSize: 18.0),
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Service',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    'Last Service: $lastServiceDate',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Next Service For Card Id: $nextServiceCard',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Next Service In: $nextService Days',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Image.network('${Data.baseUrl}/media/utils/Service_Illus.jpg', height: 400),
            ),
            const SizedBox(height: 10.0),

            lastButton
                ? buildServiceButton(
                    label: 'Cancelled Service',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceLast(serviceData: cancelServices.last))),
                  )
                : Container(),

            const SizedBox(height: 15.0),

            bookButton
                ? buildServiceButton(
                    label: 'Book Service',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceBook())),
                  )
                : buildServiceButton(
                    label: 'Service Details',
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ServiceDetails(serviceData: bookedServices.last))),
                  ),
          ],
        ),
      ),
    );
  }
}
