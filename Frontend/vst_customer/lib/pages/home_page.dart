import 'package:flutter/material.dart';
import 'contact.dart';
import 'data.dart';
import 'help.dart';
import 'package:dio/dio.dart';
import 'settings.dart';
import '../app_localizations.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToIndex;
  const HomePage({super.key, required this.onNavigateToIndex});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Dio _dio = Dio();
  List<String> quotes = [
    "I will love the light for it shows me the way, yet I will endure the darkness because it shows me the stars.",
    "OG Mandino"
  ];

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
          quotes = List<String>.from(response.data['quotes']);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final List<Map<String, dynamic>> buttonData = [
      {'icon': Icons.construction, 'label': 'Service', 'onTap': () => widget.onNavigateToIndex(1)},
      {'icon': Icons.phone, 'label': 'Contact', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage()))},
      {'icon': Icons.article, 'label': 'Card', 'onTap': () => widget.onNavigateToIndex(3)},
      {'icon': Icons.settings, 'label': AppLocalizations.of(context).translate('settings'), 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()))},
      {'icon': Icons.notifications, 'label': 'Alerts', 'onTap': () => print('Alerts tapped')},
      {'icon': Icons.shopping_bag, 'label': 'Products', 'onTap': () => widget.onNavigateToIndex(2)},
      {'icon': Icons.help, 'label': 'Help', 'onTap': () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()))},
      {'icon': Icons.person, 'label': 'Profile', 'onTap': () => widget.onNavigateToIndex(4)},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: screenWidth * 0.8 * 9 / 16,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.9, initialPage: 1000),
                itemBuilder: (context, index) {
                  int actualIndex = index % 3;
                  return Container(
                    width: screenWidth * 0.9,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage('${Data.baseUrl}/media/banners/banner$actualIndex.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildIconButton(screenWidth, buttonData[index])),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) => _buildIconButton(screenWidth, buttonData[index + 4])),
            ),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '"${quotes.isNotEmpty ? quotes[0] : "Loading..."}"',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '- ${quotes.length > 1 ? quotes[1] : ""}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(double screenWidth, Map<String, dynamic> data) {
    return InkWell(
      onTap: data['onTap'],
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: screenWidth / 6,
        height: screenWidth / 6,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 55, 99, 174),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(data['icon'], size: screenWidth / 18, color: Colors.white70),
            const SizedBox(height: 8),
            Text(data['label'], style: TextStyle(fontSize: screenWidth / 35, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
