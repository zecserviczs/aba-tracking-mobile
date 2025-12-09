import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/planning_models.dart';
import 'api_service.dart';

class PlanningService {
  
  // Obtenir le planning d'une journée
  static Future<DailyPlanning?> getPlanningByDate(int childId, String date) async {
    try {
      final response = await ApiService.get('/planning/child/$childId/date/$date');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['message'] != null) {
          // Aucun planning pour cette date
          return null;
        }
        return DailyPlanning.fromJson(data);
      } else {
        throw Exception('Erreur lors de la récupération du planning');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Sauvegarder un planning
  static Future<Map<String, dynamic>> savePlanning(int childId, Map<String, dynamic> planningData) async {
    try {
      final response = await ApiService.post('/planning/child/$childId', planningData);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la sauvegarde du planning');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Obtenir l'historique des plannings
  static Future<List<DailyPlanning>> getPlanningHistory(int childId) async {
    try {
      final response = await ApiService.get('/planning/child/$childId/history');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((p) => DailyPlanning.fromJson(p)).toList();
      } else {
        throw Exception('Erreur lors de la récupération de l\'historique');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Copier un planning
  static Future<Map<String, dynamic>> copyPlanning(
      int childId, String sourceDate, String targetDate) async {
    try {
      final response = await ApiService.post('/planning/child/$childId/copy', {
        'sourceDate': sourceDate,
        'targetDate': targetDate,
      });
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur lors de la copie du planning');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Supprimer un planning
  static Future<bool> deletePlanning(int planningId) async {
    try {
      final response = await ApiService.delete('/planning/$planningId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les templates
  static Future<List<DailyPlanning>> getTemplates(int childId) async {
    try {
      final response = await ApiService.get('/planning/child/$childId/templates');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((p) => DailyPlanning.fromJson(p)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des templates');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}






