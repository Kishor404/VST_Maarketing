import 'package:flutter/material.dart';
import 'product_details.dart';
import 'api.dart';
import 'login_page.dart';
import '../app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtils

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<dynamic> products = [];
  Map<String, dynamic> apiData = {};
  bool isLoading = true;
  API api = API();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    apiData = await api.fetchProducts();
    if (apiData["logout"]==1) {
      _logout();
    } else {
      products = apiData["data"];
      setState(() {
        isLoading = false;
      });
    }
  }
  

  Future<void> _logout() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtils
    ScreenUtil.init(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.w), // Use ScreenUtil for padding
                  child: Text(
                    AppLocalizations.of(context).translate('product_title'),
                    style: TextStyle(
                      fontSize: 18.sp, // Use ScreenUtil for font size
                      color: Color.fromARGB(255, 55, 99, 174),
                    ),
                  ),
                ),
                Expanded(
                  child: products.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context).translate('product_no_product'),
                            style: TextStyle(fontSize: 16.sp, color: Colors.grey), // Use ScreenUtil for font size
                          ),
                        )
                      : SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(30.w), // Use ScreenUtil for padding
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1,
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                bool isLastColumn = (index + 1) % 2 == 0;
                                bool isLastRow = index >= products.length - 2;

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: isLastColumn
                                          ? BorderSide.none
                                          : BorderSide(
                                              color: Color.fromARGB(255, 131, 131, 131),
                                              width: 1.0),
                                      bottom: isLastRow
                                          ? BorderSide.none
                                          : BorderSide(
                                              color: Color.fromARGB(255, 131, 131, 131),
                                              width: 1.0),
                                    ),
                                  ),
                                  child: ProductTile(
                                    productName: product['name'],
                                    productImage: product['image'],
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductDetailsPage(
                                            productName: product['name'],
                                            productImg: product['image'],
                                            productDet: product['details'],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class ProductTile extends StatelessWidget {
  final String productName;
  final String productImage;
  final VoidCallback onTap;

  const ProductTile({
    required this.productName,
    required this.productImage,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(20.w), // Use ScreenUtil for padding
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h), // Use ScreenUtil for vertical padding
                child: Image.network(
                  productImage,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Text(
              productName,
              style: TextStyle(
                fontSize: 12.sp, // Use ScreenUtil for font size
                color: Color.fromARGB(255, 55, 99, 174),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
