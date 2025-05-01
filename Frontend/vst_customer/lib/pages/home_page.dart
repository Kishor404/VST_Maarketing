import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'contact.dart';
import 'data.dart';
import 'help.dart';
import 'package:dio/dio.dart';
import 'settings.dart';
import '../app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToIndex;
  const HomePage({super.key, required this.onNavigateToIndex});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> cardData = [];
  List<Map<String, dynamic>> warrentyData = [];
  bool isLoading = true;
  final Dio _dio = Dio();

  late PageController _cardPageController;
  int _currentCardPage = 0;

  @override
  void initState() {
    super.initState();
    _cardPageController = PageController();
    _initializeData();
  }

  @override
  void dispose() {
    _cardPageController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await fetchCards();
  }

  Future _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString('RT') ?? '';
    return refreshToken;
  }

  Future _refreshAccessToken() async {
    String refreshToken = await _loadTokens();
    if (refreshToken.isEmpty) {
      await _handleLogout();
      return;
    }

    final url = '${Data.baseUrl}/log/token/refresh/';
    final requestBody = {'refresh': refreshToken};

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
        return newAccessToken;
      } else {
        debugPrint("Refresh token expired or invalid. Logging out...");
        await _handleLogout();
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await _handleLogout();
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> fetchCards() async {
    String accessToken = await _refreshAccessToken();

    if (accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch cards.");
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/api/cards-details/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
        setState(() {
          cardData = List<Map<String, dynamic>>.from(response.data);
          isLoading = false;
        });
        await getWarrentyDetails(response.data);
      } else {
        debugPrint("Unexpected response format: ${response.data}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchCards(); // Retry fetching after token refresh
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching cards: $e');
    }
  }

  Future<Map<String, dynamic>> fetchWarrentyDataByCardId(cid) async {
    String accessToken = await _refreshAccessToken();
    try {
      final response = await _dio.get(
        '${Data.baseUrl}/utils/getwarrentydetails/$cid',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
    return {};
  }

  Future<void> getWarrentyDetails(cData) async {
    if (cData.isEmpty) {
      return;
    }
    for (int i = 0; i < cData.length; i++) {
      var cid = cData[i]['id'];
      var data = await fetchWarrentyDataByCardId(cid);
      if (data.isNotEmpty) {
        setState(() {
          warrentyData.add(data);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttonData = [
      {'icon': Icons.construction, 'label': AppLocalizations.of(context).translate('home_service'), 'onTap': () => widget.onNavigateToIndex(1)},
      {'icon': Icons.phone, 'label': AppLocalizations.of(context).translate('home_contact'), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()))},
      {'icon': Icons.article, 'label': AppLocalizations.of(context).translate('home_card'), 'onTap': () => widget.onNavigateToIndex(3)},
      {'icon': Icons.settings, 'label': AppLocalizations.of(context).translate('home_setting'), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()))},
      {'icon': Icons.notifications, 'label': AppLocalizations.of(context).translate('home_alert'), 'onTap': () => print('Alerts tapped')},
      {'icon': Icons.shopping_bag, 'label': AppLocalizations.of(context).translate('home_product'), 'onTap': () => widget.onNavigateToIndex(2)},
      {'icon': Icons.help, 'label': AppLocalizations.of(context).translate('home_help'), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()))},
      {'icon': Icons.person, 'label': AppLocalizations.of(context).translate('home_profile'), 'onTap': () => widget.onNavigateToIndex(4)},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150.h,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9, initialPage: 1000),
                itemBuilder: (context, index) {
                  int actualIndex = index % 3;
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 8.sp),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10.sp),
                      image: DecorationImage(
                        image: NetworkImage('${Data.baseUrl}/media/Banners/banner$actualIndex.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 50.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildIconButton(buttonData[index])),
            ),
            SizedBox(height: 20.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildIconButton(buttonData[index + 4])),
            ),
            SizedBox(height: 50.sp),
            Expanded(
  child: Container(
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(10.sp),
    ),
    child: Center(
      child: SizedBox(
        width: 260.w,
        child: cardData.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _cardPageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentCardPage = index;
                        });
                      },
                      itemCount: cardData.length,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Warranty For ${cardData[index]['model']} (${cardData[index]['id']})',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            SizedBox(height: 8.sp),
                            warrentyData.length > index
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 8.w,
                                            height: 8.w,
                                            decoration: BoxDecoration(
                                              color: warrentyData[index]['is_warranty'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          SizedBox(width: 6.w),
                                          Text(
                                            warrentyData[index]['is_warranty'] == true
                                                ? "On Warranty Period"
                                                : "Warranty Expired",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: warrentyData[index]['is_warranty'] == true
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (warrentyData[index]['is_warranty'] != true) ...[
                                        SizedBox(height: 8.sp),
                                        Text(
                                          "Contact VST Marketing to Extend the Warranty or Activate ACM",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 10.sp, color: Colors.black),
                                        ),
                                      ]
                                    ],
                                  )
                                : Text(
                                    'Loading warranty info...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(cardData.length, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        width: _currentCardPage == index ? 6.w : 4.w,
                        height: _currentCardPage == index ? 6.w : 4.w,
                        decoration: BoxDecoration(
                          color: _currentCardPage == index ? Colors.black : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10.h),
                ],
              )
            : Center(
                child: Text(
                  "Get Service Card from VST Maarketing To View Warranty Details...",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
      ),
    ),
  ),
)

                                ],
                              ),
                            ),
                          );
                        }

  Widget _buildIconButton(Map<String, dynamic> data) {
  return InkWell(
    onTap: data['onTap'],
    borderRadius: BorderRadius.circular(8.sp),
    child: Container(
      width: 65.w,
      height: 58.h,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 55, 99, 174),
        borderRadius: BorderRadius.circular(8.sp),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(85, 0, 0, 0), // shadow color
            blurRadius: 6,          // soft blur radius
            offset: Offset(3, 3),   // horizontal and vertical offset
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data['icon'], size: 20.sp, color: const Color.fromARGB(228, 255, 255, 255)),
          SizedBox(height: 5.sp),
          Text(data['label'], style: TextStyle(fontSize: 11.sp, color: const Color.fromARGB(228, 255, 255, 255))),
        ],
      ),
    ),
  );
}

}
