import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';
import '../models/child_model.dart';
import '../models/social_scenario_models.dart';

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
      String endpoint;
      if (userType == 'parent') {
        endpoint = '$baseUrl/auth/login';
      } else if (userType == 'child') {
        endpoint = '$baseUrl/child/login';
      } else {
        endpoint = '$baseUrl/professional/login';
      }
          
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

  // Google Authentication
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String idToken,
    required String userType,
  }) async {
    try {
      String endpoint;
      if (userType == 'parent') {
        endpoint = '$baseUrl/auth/google';
      } else {
        endpoint = '$baseUrl/professional/google';
      }
          
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
          'userType': userType,
        }),
      );

      _logger.d('Google login response: ${response.statusCode} - ${response.body}');

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
        throw Exception('Erreur de connexion Google: ${response.body}');
      }
    } catch (e) {
      _logger.e('Google login error: $e');
      rethrow;
    }
  }
  
  // Child Dashboard methods
  static Future<Map<String, dynamic>> getChildInfo() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/child/dashboard/me'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération des infos enfant');
    }
  }
  
  static Future<Map<String, dynamic>> getChildTodayPlanning() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/child/dashboard/planning/today'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du planning');
    }
  }
  
  static Future<Map<String, dynamic>> getChildPlanningByDate(String date) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/child/dashboard/planning/date/$date'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du planning');
    }
  }
  
  static Future<List<SocialScenarioModel>> getChildScenarios() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/child/dashboard/scenarios'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SocialScenarioModel.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des scénarios');
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

  // Professional scenarios
  static Future<List<SocialScenarioModel>> getProfessionalScenarios(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    _logger.d('Get professional scenarios $endpoint: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SocialScenarioModel.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des scénarios');
  }

  static Future<List<SocialScenarioModel>> getMyProfessionalScenarios() {
    return getProfessionalScenarios('/social-scenarios/my-scenarios');
  }

  static Future<List<SocialScenarioModel>> getPendingProfessionalScenarios() {
    return getProfessionalScenarios('/social-scenarios/pending-for-professional');
  }

  static Future<List<SocialScenarioModel>> getValidatedProfessionalScenarios() {
    return getProfessionalScenarios('/social-scenarios/validated-for-professional');
  }

  // Parent scenarios
  static Future<List<SocialScenarioModel>> getParentScenarios() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/parent/scenarios/me'), headers: headers);
    _logger.d('Get parent scenarios: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SocialScenarioModel.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des scénarios parent');
  }

  static Future<SocialScenarioModel> getScenarioById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/social-scenarios/$id'), headers: headers);
    _logger.d('Get scenario $id: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SocialScenarioModel.fromJson(data);
    }
    throw Exception('Scénario introuvable');
  }

  static Future<List<ScenarioGenerationContext>> getScenarioGenerationContexts() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/social-scenarios/contexts'), headers: headers);
    _logger.d('Get scenario contexts: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ScenarioGenerationContext.fromJson(json)).toList();
    }
    throw Exception('Erreur lors de la récupération des contextes');
  }

  static Future<List<SocialScenarioModel>> autoGenerateScenarios({
    required int childId,
    required String contextCode,
    required int count,
  }) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
        '$baseUrl/social-scenarios/child/$childId/auto-generate?context=$contextCode&count=$count');
    final response = await http.post(uri, headers: headers);
    _logger.d('Auto-generate scenarios: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SocialScenarioModel.fromJson(json)).toList();
    }
    throw Exception(jsonDecode(response.body)['error'] ?? 'Erreur lors de la génération automatique');
  }

  static Future<void> validateScenario(int scenarioId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/social-scenarios/$scenarioId/validate'),
      headers: headers,
    );
    _logger.d('Validate scenario $scenarioId: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      throw Exception(body?['error'] ?? 'Erreur lors de la validation du scénario');
    }
  }

  // Actuator
  static Future<Map<String, dynamic>> getActuatorHealth() async {
    final headers = await _getHeaders();
    headers['Accept'] = 'application/vnd.spring-boot.actuator.v3+json';

    final response = await http.get(
      Uri.parse('http://localhost:8080/actuator/health'),
      headers: headers,
    );
    _logger.d('GET /actuator/health: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Erreur Actuator: ${response.statusCode}');
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

  // Add child
  static Future<void> addChild(String name, int age, {String? email, String? password}) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'name': name,
        'age': age,
      };
      
      if (email != null && email.isNotEmpty) {
        body['email'] = email;
      }
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/children'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        throw Exception(errorBody?['error'] ?? 'Erreur lors de l\'ajout de l\'enfant');
      }
    } catch (e) {
      _logger.e('Add child error: $e');
      rethrow;
    }
  }

  // Create or update child account
  static Future<void> createOrUpdateChildAccount(int childId, String email, {String? password}) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{
        'email': email,
      };
      
      if (password != null && password.isNotEmpty) {
        body['password'] = password;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/children/$childId/account'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        throw Exception(errorBody?['error'] ?? 'Erreur lors de la création du compte');
      }
    } catch (e) {
      _logger.e('Create child account error: $e');
      rethrow;
    }
  }

  // Delete child
  static Future<void> deleteChild(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/children/$childId'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'enfant');
      }
    } catch (e) {
      _logger.e('Delete child error: $e');
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

  // Helper method for POST requests that parse JSON response
  static Future<Map<String, dynamic>> httpPost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await post(endpoint, body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      throw Exception(errorBody?['error'] ?? 'Erreur lors de la requête');
    }
  }
}

