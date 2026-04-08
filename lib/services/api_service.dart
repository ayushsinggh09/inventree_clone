import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // static const String baseUrl = 'http://127.0.0.1';
  static const String baseUrl = 'http://127.0.0.1:8080';

  static String? _token;



  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static bool get isLoggedIn => _token != null;


  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Token $_token',
  };


  static Future<bool> login(String username, String password) async {
    try {
      String basicAuth = 'Basic ' + base64Encode(utf8.encode('$username:$password'));
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/token/'),
        headers: {
          'Authorization': basicAuth,
          'Accept': 'application/json',
        },
      );
      print('Login status: ${response.statusCode}');
      print('Login body: ${response.body}');
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }


  static Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      print('GET $endpoint -> ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('GET failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET error: $e');
      return null;
    }
  }

  //APIs

  static Future<List<dynamic>> getParts() async {
    final data = await _get('/api/part/?limit=50');
    return data?['results'] ?? [];
  }

  static Future<List<dynamic>> getStockItems() async {
    final data = await _get('/api/stock/?limit=50');
    return data?['results'] ?? [];
  }

  static Future<List<dynamic>> getStockLocations() async {
    final data = await _get('/api/stock/location/?limit=50');
    return data?['results'] ?? [];
  }

  static Future<List<dynamic>> getPartCategories() async {
    final data = await _get('/api/part/category/?limit=50');
    return data?['results'] ?? [];
  }

  // DASHBOARD

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
      print('Dashboard error: $e');
      return {
        'total_parts': 0,
        'total_stock': 0,
        'total_locations': 0,
        'total_categories': 0,
      };
    }
  }
}