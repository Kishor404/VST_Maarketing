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
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          productName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp, // Use ScreenUtil for font size
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Center( // 👈 Center horizontally
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  productImg,
                  height: 200.h,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  productName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 55, 99, 174),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  productDet,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
