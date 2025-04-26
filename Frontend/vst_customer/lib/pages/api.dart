import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class API{

  final Dio _dio = Dio();
  String baseUrl = "http://157.173.220.208";

  // ==============================================================================

  // 0.1 Load Tokens
  // 0.2 Logout when token expires
  // 0.3 Refresh Access Token

  // 1. FETCH PRODUCTS
  // 2. FETCH SERVICES
  // 3. FETCH NEXT SERVICE

  // ==============================================================================

  // ================ LOAD THE TOKENS ===================

  Future _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    String refreshToken = prefs.getString('RT') ?? '';
    return refreshToken;
  }

  // =========== LOGOUT WHEN TOPKEN EXPIRE ==============

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // =========== REFRESH THE ACCESS TOKEN ==============

  Future _refreshAccessToken() async {

    String refreshToken = await _loadTokens();

    if (refreshToken.isEmpty) {
      await _logout();
      return;
    }

    final url = '$baseUrl/log/token/refresh/';
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
        await _logout();
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await _logout();
    }
  }

  // =====================================================================================

  // ================ 1. FETCH PRODUCTS ===================

  Future<Map<String, dynamic>> fetchProducts() async {

    String accessToken= await _refreshAccessToken();

    if (accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch products.");
      await _logout();
      return {"data":[],"logout": 1};
    }

    try {
      final response = await _dio.get(
        '$baseUrl/products/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      return {"data":response.data, "logout": 0};
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchProducts(); // Retry fetching after token refresh
      }
      debugPrint('Error fetching products: $e');
    }

    return {"data":[],"logout": 0};
  }

// ======================== 2. FETCH SERVICES ==================================

Future<Map<String, dynamic>> fetchServices() async {

    String accessToken= await _refreshAccessToken();

    if (accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      await _logout();
      return {"logout":1, "data": []};
    }

    try {
      final response = await _dio.get(
        '$baseUrl/services/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      List<dynamic> services = response.data;

      return {"data":services, "logout":0}; // Process fetched services
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchServices();
      }

      debugPrint('Error fetching services: $e');
    }
    return {"logout":0, "data":[]};
  }


// ======================== 3. FETCH NEXT SERVICE ==================================

  Future<Map<String, dynamic>> fetchNextService() async {
    String accessToken= await _refreshAccessToken();

    if (accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch services.");
      await _logout();
      return {"logout":1, "nextService": "No Service Data", "nextServiceCard": "No Service Data"};
    }

    try {
      final response = await _dio.get(
        '$baseUrl/utils/next-service/',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      String nextService = response.data["days_remaining"].toString();
      String nextServiceCard = response.data["card_id"].toString();

      return {"nextService": nextService, "nextServiceCard": nextServiceCard};

    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        debugPrint("Access token expired. Refreshing token...");
        await _refreshAccessToken();
        return fetchNextService();
      }
      debugPrint('Error fetching next service: $e');
    }
    return {"logout":0, "nextService": "No Service Data", "nextServiceCard": "No Service Data"};
  }

  // =======================================================================================================

  Future<Map<String, dynamic>> cancelService(String serviceId) async {
    String accessToken= await _refreshAccessToken();

    if (accessToken.isEmpty) {
      debugPrint("No access token available. Cannot fetch products.");
      await _logout();
      return {"data":false,"logout": 1};
    }

    final String url = '$baseUrl/services/cancleservicebycustomer/$serviceId';
    final Dio dio = Dio();

    try {
      final response = await dio.patch(
        url,
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("Service cancelled successfully.");
        return {"data":true,"logout": 1};
      } else {
        debugPrint("Failed to cancel service. Status: ${response.statusCode}");
        return {"data":true,"logout": 1};
      }
    } catch (e) {
      debugPrint("Error cancelling service: $e");
      return {"data":true,"logout": 1};
    }
  }



}
