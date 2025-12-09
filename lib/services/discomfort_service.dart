import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/planning_models.dart';
import 'api_service.dart';

class DiscomfortService {
  
  // Obtenir les inconforts d'un enfant
  static Future<List<DiscomfortItem>> getDiscomforts(int childId) async {
    try {
      final response = await ApiService.get('/discomfort/child/$childId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((d) => DiscomfortItem.fromJson(d)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des inconforts');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Créer un inconfort
  static Future<DiscomfortItem> createDiscomfort(int childId, DiscomfortItem discomfort) async {
    try {
      final response = await ApiService.post('/discomfort/child/$childId', discomfort.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return DiscomfortItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de l\'inconfort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Mettre à jour un inconfort
  static Future<DiscomfortItem> updateDiscomfort(int discomfortId, DiscomfortItem discomfort) async {
    try {
      final response = await ApiService.put('/discomfort/$discomfortId', discomfort.toJson());
      
      if (response.statusCode == 200) {
        return DiscomfortItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'inconfort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un inconfort
  static Future<bool> deleteDiscomfort(int discomfortId) async {
    try {
      final response = await ApiService.delete('/discomfort/$discomfortId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les statistiques des inconforts
  static Future<Map<String, dynamic>> getDiscomfortStats(int childId) async {
    try {
      final response = await ApiService.get('/discomfort/child/$childId/stats');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}






