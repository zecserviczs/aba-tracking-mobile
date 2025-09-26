import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comfort_models.dart';
import 'api_service.dart';

class ComfortService {
  static const String _baseEndpoint = '/api/comfort';

  // ========== ROUTINES ==========

  /// Créer une nouvelle routine
  static Future<Routine> createRoutine(Routine routine) async {
    try {
      final response = await ApiService.post('$_baseEndpoint/routines', routine.toJson());
      if (response.statusCode == 200) {
        return Routine.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de la routine');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir toutes les routines d'un enfant
  static Future<List<Routine>> getChildRoutines(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/routines');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Routine.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des routines');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les routines actives d'un enfant
  static Future<List<Routine>> getActiveChildRoutines(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/routines/active');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Routine.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des routines actives');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les routines par type
  static Future<List<Routine>> getRoutinesByType(int childId, RoutineType type) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/routines/type/${type.name}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Routine.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des routines par type');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les routines du matin
  static Future<List<Routine>> getMorningRoutines(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/routines/morning');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Routine.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des routines du matin');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les routines du soir
  static Future<List<Routine>> getEveningRoutines(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/routines/evening');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Routine.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des routines du soir');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour une routine
  static Future<Routine> updateRoutine(int routineId, Routine routine) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/routines/$routineId', routine.toJson());
      if (response.statusCode == 200) {
        return Routine.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de la routine');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Activer/Désactiver une routine
  static Future<Routine> toggleRoutine(int routineId) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/routines/$routineId/toggle', {});
      if (response.statusCode == 200) {
        return Routine.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du changement d\'état de la routine');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Supprimer une routine
  static Future<void> deleteRoutine(int routineId) async {
    try {
      final response = await ApiService.delete('$_baseEndpoint/routines/$routineId');
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la routine');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== ÉLÉMENTS DE CONFORT ==========

  /// Créer un nouvel élément de confort
  static Future<ComfortItem> createComfortItem(ComfortItem item) async {
    try {
      final response = await ApiService.post('$_baseEndpoint/items', item.toJson());
      if (response.statusCode == 200) {
        return ComfortItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de l\'élément de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir tous les éléments de confort d'un enfant
  static Future<List<ComfortItem>> getChildComfortItems(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments disponibles d'un enfant
  static Future<List<ComfortItem>> getAvailableComfortItems(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/available');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments disponibles');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments critiques d'un enfant
  static Future<List<ComfortItem>> getCriticalComfortItems(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/critical');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments critiques');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments par type
  static Future<List<ComfortItem>> getComfortItemsByType(int childId, ComfortItemType type) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/type/${type.name}');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments par type');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments par catégorie
  static Future<List<ComfortItem>> getComfortItemsByCategory(int childId, int categoryId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/category/$categoryId');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments par catégorie');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Rechercher des éléments de confort
  static Future<List<ComfortItem>> searchComfortItems(int childId, String searchTerm) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/search?q=$searchTerm');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la recherche d\'éléments de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour un élément de confort
  static Future<ComfortItem> updateComfortItem(int itemId, ComfortItem item) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/items/$itemId', item.toJson());
      if (response.statusCode == 200) {
        return ComfortItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'élément de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marquer un élément comme utilisé
  static Future<ComfortItem> markComfortItemAsUsed(int itemId) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/items/$itemId/mark-used', {});
      if (response.statusCode == 200) {
        return ComfortItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du marquage de l\'élément comme utilisé');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Supprimer un élément de confort
  static Future<void> deleteComfortItem(int itemId) async {
    try {
      final response = await ApiService.delete('$_baseEndpoint/items/$itemId');
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'élément de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== CATÉGORIES ==========

  /// Obtenir toutes les catégories
  static Future<List<ComfortCategory>> getAllCategories() async {
    try {
      final response = await ApiService.get('$_baseEndpoint/categories');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => ComfortCategory.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des catégories');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== STATISTIQUES ==========

  /// Obtenir les statistiques de confort d'un enfant
  static Future<ComfortStats> getComfortStats(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/stats');
      if (response.statusCode == 200) {
        return ComfortStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des statistiques de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}

