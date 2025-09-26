import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/child_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  static final Logger _logger = Logger();
  
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    _logger.d('Current token: ${token != null ? token.substring(0, 20) + '...' : 'null'}');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Authentication
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String userType,
  }) async {
    try {
      final endpoint = userType == 'parent' 
          ? '$baseUrl/auth/login'
          : '$baseUrl/professional/login';
          
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      _logger.d('Login response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['accessToken'];
        
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', token);
          await prefs.setString('userType', userType);
        }
        
        return data;
      } else {
        throw Exception('Erreur de connexion: ${response.body}');
      }
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  // Get current user
  static Future<User> getCurrentUser({String? userType}) async {
    try {
      final headers = await _getHeaders();
      
      // Déterminer l'endpoint selon le type d'utilisateur
      String endpoint;
      if (userType == 'parent') {
        endpoint = '$baseUrl/parent/me';
      } else {
        endpoint = '$baseUrl/professional/me';
      }
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      _logger.d('Get current user response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        
        // Sauvegarder les rôles de l'utilisateur
        if (user.roles?.isNotEmpty == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userRoles', user.roles!.join(','));
        }
        
        return user;
      } else {
        throw Exception('Erreur lors de la récupération de l\'utilisateur');
      }
    } catch (e) {
      _logger.e('Get current user error: $e');
      rethrow;
    }
  }

  // Get authorized children
  static Future<List<Child>> getAuthorizedChildren({String? userType}) async {
    try {
      final headers = await _getHeaders();
      
      // Déterminer l'endpoint selon le type d'utilisateur
      String endpoint;
      if (userType == 'parent') {
        endpoint = '$baseUrl/parent/my-children';
      } else {
        endpoint = '$baseUrl/professional/authorized-children';
      }
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers,
      );

      _logger.d('Get children response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Child.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des enfants');
      }
    } catch (e) {
      _logger.e('Get authorized children error: $e');
      rethrow;
    }
  }

  // Get observations by child
  static Future<List<ABAObservation>> getObservationsByChild(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/observations/by-child/$childId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ABAObservation.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des observations');
      }
    } catch (e) {
      _logger.e('Get observations error: $e');
      rethrow;
    }
  }

  // Add observation
  static Future<void> addObservation({
    required int childId,
    required String behaviorType,
    required String severity,
    required String antecedents,
    required String observer,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/observations'),
        headers: headers,
        body: jsonEncode({
          'childId': childId,
          'behaviorType': behaviorType,
          'severity': severity,
          'antecedents': antecedents,
          'observer': observer,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Erreur lors de l\'ajout de l\'observation');
      }
    } catch (e) {
      _logger.e('Add observation error: $e');
      rethrow;
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userType');
    await prefs.remove('userRoles');
  }

  // Clear all cached data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Generic HTTP methods for admin service
  static Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _logger.d('GET $endpoint: ${response.statusCode} - ${response.body}');
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    _logger.d('POST $endpoint: ${response.statusCode} - ${response.body}');
    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: jsonEncode(body),
    );
    _logger.d('PUT $endpoint: ${response.statusCode} - ${response.body}');
    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
    _logger.d('DELETE $endpoint: ${response.statusCode} - ${response.body}');
    return response;
  }
}

