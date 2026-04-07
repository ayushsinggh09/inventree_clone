import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://inventree.localhost';
  static String? _token;

  // Load saved token on app start
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token after login
  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token on logout
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isLoggedIn => _token != null;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Token $_token',
  };

  // login
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get part
  static Future<List<dynamic>> getParts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/part/?limit=50'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // GET Stock items
  static Future<List<dynamic>> getStockItems() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stock/?limit=50'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  //get stk location
  static Future<List<dynamic>> getStockLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/stock/location/?limit=50'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  //get parts catego..
  static Future<List<dynamic>> getPartCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/part/category/?limit=50'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // GET DASHBOARD STATS
  static Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final parts = await getParts();
      final stock = await getStockItems();
      final locations = await getStockLocations();
      final categories = await getPartCategories();
      return {
        'total_parts': parts.length,
        'total_stock': stock.length,
        'total_locations': locations.length,
        'total_categories': categories.length,
      };
    } catch (e) {
      return {
        'total_parts': 0,
        'total_stock': 0,
        'total_locations': 0,
        'total_categories': 0,
      };
    }
  }
}