import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../models/subscription_model.dart';

class SubscriptionService {
  static const String baseUrl = 'http://localhost:8080/api';
  static final Logger _logger = Logger();

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>?> getCurrentSubscription() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/current'),
        headers: headers,
      );

      _logger.d('Current subscription response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        _logger.w('Failed to get current subscription: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Get current subscription error: $e');
      return null;
    }
  }

  static Future<List<SubscriptionType>> getAvailableSubscriptionTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/types'),
        headers: headers,
      );

      _logger.d('Available subscription types response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SubscriptionType.fromJson(json)).toList();
      } else {
        _logger.w('Failed to get subscription types: ${response.statusCode}');
        return _getDefaultSubscriptionTypes();
      }
    } catch (e) {
      _logger.e('Get subscription types error: $e');
      return _getDefaultSubscriptionTypes();
    }
  }

  static Future<List<Subscription>> getSubscriptionHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/history'),
        headers: headers,
      );

      _logger.d('Subscription history response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        _logger.w('Failed to get subscription history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      _logger.e('Get subscription history error: $e');
      return [];
    }
  }

  static Future<bool> subscribe(String subscriptionType, String paymentMethod, String transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/subscribe'),
        headers: headers,
        body: jsonEncode({
          'type': subscriptionType,
          'paymentMethod': paymentMethod,
          'transactionId': transactionId,
        }),
      );

      _logger.d('Subscribe response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        _logger.w('Failed to subscribe: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Subscribe error: $e');
      return false;
    }
  }

  static Future<bool> cancelSubscription(int subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions/cancel/$subscriptionId'),
        headers: headers,
      );

      _logger.d('Cancel subscription response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      } else {
        _logger.w('Failed to cancel subscription: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Cancel subscription error: $e');
      return false;
    }
  }

  static Future<SubscriptionLimits?> getSubscriptionLimits() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions/limits'),
        headers: headers,
      );

      _logger.d('Subscription limits response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionLimits.fromJson(data);
      } else {
        _logger.w('Failed to get subscription limits: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      _logger.e('Get subscription limits error: $e');
      return null;
    }
  }

  static List<SubscriptionType> _getDefaultSubscriptionTypes() {
    return [
      SubscriptionType(
        name: 'FREEMIUM',
        displayName: 'Freemium',
        price: 0.0,
        durationDays: 30,
        maxObservationsPerMonth: 5,
        maxChildren: 10,
        hasAdvancedAnalytics: false,
        hasPrioritySupport: false,
        description: 'Accès de base avec limitations',
        features: [
          'Jusqu\'à 5 observations par mois',
          'Jusqu\'à 10 enfants',
          'Analyses de base',
          'Support par email'
        ],
      ),
      SubscriptionType(
        name: 'PREMIUM',
        displayName: 'Premium',
        price: 19.99,
        durationDays: 365,
        maxObservationsPerMonth: 50,
        maxChildren: 100,
        hasAdvancedAnalytics: true,
        hasPrioritySupport: true,
        description: 'Fonctionnalités avancées et support prioritaire',
        features: [
          'Jusqu\'à 50 observations par mois',
          'Jusqu\'à 100 enfants',
          'Analyses avancées',
          'Support prioritaire',
          'Rapports détaillés'
        ],
      ),
      SubscriptionType(
        name: 'EXCELLENCE',
        displayName: 'Excellence',
        price: 39.99,
        durationDays: 365,
        maxObservationsPerMonth: -1,
        maxChildren: -1,
        hasAdvancedAnalytics: true,
        hasPrioritySupport: true,
        description: 'Accès complet sans limitations',
        features: [
          'Observations illimitées',
          'Enfants illimités',
          'Analyses avancées',
          'Support prioritaire',
          'Rapports détaillés',
          'Intelligence artificielle complète'
        ],
      ),
    ];
  }
}








