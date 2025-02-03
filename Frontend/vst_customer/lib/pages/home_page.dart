import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the screen width using MediaQuery
    double screenWidth = MediaQuery.of(context).size.width;

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
                  viewportFraction: 0.9, // Each page takes 50% of the screen width
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
                        image: NetworkImage('http://127.0.0.1:8000/media/banners/banner$actualIndex.jpg'), // Fetch from URL
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
                (index) => Container(
                  width: screenWidth / 6,
                  height: screenWidth / 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star, // Replace with your desired icon
                        size: screenWidth / 20,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8), // Spacing between the icon and label
                      Text(
                        'Label $index', // Replace with your desired label
                        style: TextStyle(
                          fontSize: screenWidth / 40,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Small buttons (Row 2)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Container(
                  width: screenWidth / 6,
                  height: screenWidth / 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star, // Replace with your desired icon
                        size: screenWidth / 20,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8), // Spacing between the icon and label
                      Text(
                        'Label $index', // Replace with your desired label
                        style: TextStyle(
                          fontSize: screenWidth / 40,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
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
}
