import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_details.dart';
import 'data.dart';


class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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
    await fetchProducts();
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

  Future<void> fetchProducts() async {
    if (_accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch products.");
      return;
    }

    try {
      final response = await _dio.get(
        '${Data.baseUrl}/products/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        }),
      );

      setState(() {
        products = response.data;
        isLoading = false;
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchProducts(); // Retry fetching after token refresh
      }

      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching products: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 55, 99, 174),
        title: const Center(
          child: Text(
            'Available Products',
            style: TextStyle(color: Colors.white, fontSize: 20.0),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                              : const BorderSide(
                                  color: Color.fromARGB(255, 131, 131, 131),
                                  width: 1.0),
                          bottom: isLastRow
                              ? BorderSide.none
                              : const BorderSide(
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
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
              style: const TextStyle(
                fontSize: 15.0,
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
