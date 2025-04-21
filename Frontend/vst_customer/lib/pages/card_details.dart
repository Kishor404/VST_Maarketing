import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data.dart';
import 'index.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardDetailsPage extends StatefulWidget {
  final Map<String, dynamic> cardData;

  const CardDetailsPage({super.key, required this.cardData});

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  String _refreshToken = '';
  String _accessToken = '';
  List<dynamic> products = [];
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
      _logout();
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
        debugPrint("Unexpected response: ${response.data}");
        _logout();
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          debugPrint("Refresh token expired! Logging out...");
          _logout();
        } else {
          debugPrint("Error refreshing token: ${e.response?.data}");
        }
      } else {
        debugPrint("Error refreshing token: $e");
      }
    }
  }

  void _showSignConfirmationDialog(BuildContext context, int serviceId) {
    showDialog(
      context: context,
      builder: (context) {
        double rating = 0;
        TextEditingController feedbackController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context).translate('card_confrim_sign')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).translate('card_confrim_sign_text')),
                  SizedBox(height: 16.h),
                  Text(AppLocalizations.of(context).translate('card_rating')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                        ),
                        color: Colors.amber,
                        onPressed: () {
                          setDialogState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: feedbackController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate('card_feedback'),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).translate('card_cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _signService(serviceId, rating, feedbackController.text, context);
                  },
                  child: Text(AppLocalizations.of(context).translate('card_confrim')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _signService(int serviceId, double rating, String feedback, BuildContext context) async {
    final dio = Dio();
    final url = '${Data.baseUrl}/api/signbycustomer/$serviceId/';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_accessToken',
    };
    final data = {
      "customer_signature": {"sign": 1},
      "feedback": feedback,
      "rating": rating.toString(),
    };

    try {
      final response = await dio.patch(url, data: data, options: Options(headers: headers));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('card_sign_success'))),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => IndexPage()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('card_sign_fail'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('card_title')),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 55, 99, 174),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Details Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: Color.fromARGB(255, 55, 99, 174),
                    width: 1.5.w,
                  ),
                ),
                color: Color.fromARGB(255, 255, 255, 255),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context).translate('card_model')} ${widget.cardData['model']}',
                        style: TextStyle(fontSize: 14.sp, color: Color.fromARGB(255, 55, 99, 174), fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      Text('${AppLocalizations.of(context).translate('card_customer_id')}${widget.cardData['customer_code']}'),
                      SizedBox(height: 8.h),
                      Text('${AppLocalizations.of(context).translate('card_date_of_installation')} ${widget.cardData['date_of_installation']}'),
                      SizedBox(height: 8.h),
                      Text('${AppLocalizations.of(context).translate('card_customer_name')} ${widget.cardData['customer_name']}'),
                      SizedBox(height: 8.h),
                      Text('${AppLocalizations.of(context).translate('card_customer_region')} ${widget.cardData['region']}'),
                      SizedBox(height: 16.h),
                      Text(
                        '${AppLocalizations.of(context).translate('card_warrenty_period')} ${widget.cardData['warranty_start_date']} - ${widget.cardData['warranty_end_date']}',
                        style: TextStyle(
                            color: Color.fromARGB(255, 55, 99, 174),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Services List
              if (widget.cardData['service_entries'] != null && widget.cardData['service_entries'] is List)
                for (var service in widget.cardData['service_entries'].reversed)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0.h),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 55, 99, 174),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 30.0.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: SingleChildScrollView(
                                child: Container(
                                  width: 400.w,
                                  padding: EdgeInsets.all(25.0.w),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${AppLocalizations.of(context).translate('card_service_no')} ${service['id']} ${AppLocalizations.of(context).translate('card_service_details')}',
                                          style: Theme.of(context).textTheme.headlineMedium),
                                      SizedBox(height: 16.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_date')} ${service['date']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_visit_type')} ${service['visit_type']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_nature_of_complaint')} ${service['nature_of_complaint']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_work_details')} ${service['work_details']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_parts_replaced')} ${service['parts_replaced']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_ICR_no')} ${service['icr_number']}'),
                                      SizedBox(height: 6.h),
                                      Text('${AppLocalizations.of(context).translate('card_service_amount_charged')} ${service['amount_charged']}'),
                                      SizedBox(height: 16.h),

                                      // Customer & CSE Signatures (if applicable)
                                      if (service['customer_signature'] != null && service['customer_signature']['sign'] != 0)
                                        Text(AppLocalizations.of(context).translate('card_service_customer_signed'), style: TextStyle(color: Colors.green)),

                                      if (service['customer_signature'] != null && service['customer_signature']['sign'] != 0)
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: Text(AppLocalizations.of(context).translate('card_service_close')),
                                        ),

                                      if (service['customer_signature'] == null || service['customer_signature']['sign'] == 0)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            ElevatedButton(
                                              onPressed: () => _showSignConfirmationDialog(context, service['id']),
                                              child: Text(AppLocalizations.of(context).translate('card_service_sign')),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text(AppLocalizations.of(context).translate('card_service_close')),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text('${AppLocalizations.of(context).translate('card_service_no')} ${service['id']} - ${service['date']}'),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
