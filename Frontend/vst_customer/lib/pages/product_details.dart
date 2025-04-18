import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class ProductDetailsPage extends StatelessWidget {
  final String productName;
  final String productImg;
  final String productDet;

  const ProductDetailsPage({
    required this.productName,
    required this.productImg,
    required this.productDet,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        title: Text(
          productName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp, // Use ScreenUtil for font size
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32.w), // Use ScreenUtil for padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                productImg,
                height: 200.h, // Use ScreenUtil for height
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20.h), // Use ScreenUtil for height spacing
              Text(
                productName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp, // Use ScreenUtil for font size
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 55, 99, 174),
                ),
              ),
              SizedBox(height: 10.h), // Use ScreenUtil for height spacing
              Text(
                productDet,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp), // Use ScreenUtil for font size
              ),
            ],
          ),
        ),
      ),
    );
  }
}
