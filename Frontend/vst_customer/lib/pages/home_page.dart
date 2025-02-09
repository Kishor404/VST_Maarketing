import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final Function(int) onNavigateToIndex; 
  const HomePage({super.key, required this.onNavigateToIndex});

  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

    // Define icons and labels for the buttons
    final List<Map<String, dynamic>> buttonData = [
      {'icon': Icons.construction, 'label': 'Service', 'onTap': () => onNavigateToIndex(1)},
      {'icon': Icons.phone, 'label': 'Contact', 'onTap': () => print('Cart tapped')},
      {'icon': Icons.article, 'label': 'View Card', 'onTap': () => onNavigateToIndex(3)},
      {'icon': Icons.settings, 'label': 'Settings', 'onTap': () => print('Settings tapped')},
      {'icon': Icons.notifications, 'label': 'Alerts', 'onTap': () => print('Alerts tapped')},
      {'icon': Icons.shopping_bag, 'label': 'Products', 'onTap': () => onNavigateToIndex(2)},
      {'icon': Icons.help, 'label': 'Help', 'onTap': () => print('Help tapped')},
      {'icon': Icons.person, 'label': 'Profile', 'onTap': () => onNavigateToIndex(4)},
    ];

    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Circularly Scrolling Banner
            SizedBox(
              height: screenWidth * 0.8 * 9 / 16, // Maintain 16:9 aspect ratio based on 40% width
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.9, // Each page takes 90% of the screen width
                  initialPage: 1000, // Infinite scroll logic
                ),
                itemBuilder: (context, index) {
                  int actualIndex = index % 3; // Number of banners
                  return Container(
                    width: screenWidth * 0.9, // Explicitly set banner width (optional)
                    margin: const EdgeInsets.symmetric(horizontal: 8), // Space between banners
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: NetworkImage(
                            'http://127.0.0.1:8000/media/banners/banner$actualIndex.jpg'), // Fetch from URL
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 50),

            // Small buttons (Row 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => _buildIconButton(
                  screenWidth,
                  buttonData[index]['icon'],
                  buttonData[index]['label'],
                  buttonData[index]['onTap'],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Small buttons (Row 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => _buildIconButton(
                  screenWidth,
                  buttonData[index + 4]['icon'],
                  buttonData[index + 4]['label'],
                  buttonData[index + 4]['onTap'],
                ),
              ),
            ),
            const SizedBox(height: 50),

            // Bottom banner
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for reusable icon button
  Widget _buildIconButton(double screenWidth, IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: screenWidth / 6,
        height: screenWidth / 6,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 55, 99, 174),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth / 23,
              color: Colors.white70,
            ),
            const SizedBox(height: 8), // Spacing between the icon and label
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth / 40,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
