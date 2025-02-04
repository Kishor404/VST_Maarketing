import 'package:flutter/material.dart';
import 'service_book.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  String lastServiceDate = "No Service Data";
  String serviceMan = "No Service Data";
  String visitType = "No Service Data";

  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> services = [];
  List<dynamic> bookedServices = [];
  List<dynamic> cancelServices = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  bool bookButton=true;
  bool lastButton=false;


  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens(); 
    await _refreshAccessToken();  
    await fetchServices();
    await fetchServiceDetails();
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

    final url = 'http://127.0.0.1:8000/log/token/refresh/';
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
        'http://127.0.0.1:8000/services/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      setState(() {
        services = response.data;
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchServices(); // Retry fetching after token refresh
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching services: $e');
    }
  }

  Future<void> fetchServiceDetails() async{
    // Simulate a backend call
    for(int i=0;i<services.length;i++){
      if(services[i]["status"]=="SD"){
        setState(() {
          lastServiceDate = services[i]["date_of_service"];
          serviceMan = services[i]['staff_name'];
          visitType = services[i]['complaint'];
        });
      }
      if(services[i]["status"]=="BD" || services[i]["status"]=="SP"){
        bookedServices.add(services[i]);
      }
      if(services[i]["status"]=="NS" || services[i]["status"]=="CC" || services[i]["status"]=="CW"){
        cancelServices.add(services[i]);
      }
    }

    if(bookedServices.isNotEmpty){
      setState(() {
        bookButton=false;
      });
    }
    if(cancelServices.isNotEmpty){
      setState(() {
        lastButton=true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth*0.8,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 55, 99, 174),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                children: [
                  const Text(
                    'Service',
                    style: TextStyle(
                      fontSize: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    'Last Service: $lastServiceDate',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Last Service By: $serviceMan',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                  Text(
                    'Next Service In: $visitType Days',
                    style: const TextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Expanded(
              child: Image.network(
                  'http://127.0.0.1:8000/media/utils/Service_Illus.jpg',
                  height: 400,
                ),
            ),
            const SizedBox(height: 10.0),

            // CANCEL BUTTON

            lastButton ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceBook(),
                                  ),
                                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 20.0),
                textStyle: const TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Last Service', style: TextStyle(color: Colors.white)),
            ) : Container(),

            // BOOK BUTTON 
            const SizedBox(height: 15.0),

            bookButton ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceBook(),
                                  ),
                                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 20.0),
                textStyle: const TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Book Service', style: TextStyle(color: Colors.white)),
            ) : ElevatedButton(
              onPressed: () {
                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceBook(),
                                  ),
                                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 55, 99, 174),
                padding: const EdgeInsets.symmetric(horizontal: 34.0, vertical: 20.0),
                textStyle: const TextStyle(fontSize: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Service Details', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
