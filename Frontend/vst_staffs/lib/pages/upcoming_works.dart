import 'package:flutter/material.dart';
import 'upcoming_works_details.dart';
import 'package:dio/dio.dart';
import 'data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingWorks extends StatefulWidget {
  const UpcomingWorks({super.key});

  @override
  State<UpcomingWorks> createState() => _UpcomingWorksState();
}

class _UpcomingWorksState extends State<UpcomingWorks> {
  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> services = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadTokens();
    await _refreshAccessToken();
    await fetchUpcomingWorks();
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

  Future<void> fetchUpcomingWorks() async {
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/utils/upcomingservice/',
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
        return fetchUpcomingWorks(); // Retry fetching after token refresh
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Upcoming Works",
          style: TextStyle(color: Color.fromRGBO(55, 99, 174, 1)),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : services.isEmpty
              ? const Center(
                  child: Text(
                    "No service available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.75,
                          child: CompletedCard(service: service),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class CompletedCard extends StatelessWidget {
  final Map<String, dynamic> service;

  const CompletedCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpcomingServiceDetails(service: service),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color.fromRGBO(55, 99, 174, 1), width: 2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12),
        elevation: 3,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(55, 99, 174, 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  'Service ID : ${service["id"]}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Name : ${service["customer_data"]["name"]}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                  Text('Card ID : ${service["card"]}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                  Text('Complaint : ${service["complaint"]}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                  Text('Date : ${service["available_date"]}',
                      style: const TextStyle(
                          fontSize: 16, color: Color.fromRGBO(55, 99, 174, 1))),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
