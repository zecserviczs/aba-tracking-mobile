import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_models.dart';
import 'api_service.dart';

class StockService {
  static const String _baseEndpoint = '/api/stock';

  // ========== CHECKLISTS ==========

  /// Créer une nouvelle checklist de stock
  static Future<StockChecklist> createStockChecklist(StockChecklist checklist) async {
    try {
      final response = await ApiService.post('$_baseEndpoint/checklists', checklist.toJson());
      if (response.statusCode == 200) {
        return StockChecklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de la checklist');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir toutes les checklists d'un enfant
  static Future<List<StockChecklist>> getChildStockChecklists(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/checklists');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockChecklist.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des checklists');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les checklists actives d'un enfant
  static Future<List<StockChecklist>> getActiveChildStockChecklists(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/checklists/active');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockChecklist.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des checklists actives');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les checklists programmées pour aujourd'hui
  static Future<List<StockChecklist>> getScheduledForToday(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/checklists/scheduled');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockChecklist.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des checklists programmées');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les checklists en retard
  static Future<List<StockChecklist>> getOverdueChecklists(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/checklists/overdue');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockChecklist.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des checklists en retard');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour une checklist
  static Future<StockChecklist> updateStockChecklist(int checklistId, StockChecklist checklist) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/checklists/$checklistId', checklist.toJson());
      if (response.statusCode == 200) {
        return StockChecklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de la checklist');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marquer une checklist comme complétée
  static Future<StockChecklist> completeStockChecklist(int checklistId) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/checklists/$checklistId/complete', {});
      if (response.statusCode == 200) {
        return StockChecklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la complétion de la checklist');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Activer/Désactiver une checklist
  static Future<StockChecklist> toggleStockChecklist(int checklistId) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/checklists/$checklistId/toggle', {});
      if (response.statusCode == 200) {
        return StockChecklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors du changement d\'état de la checklist');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Supprimer une checklist
  static Future<void> deleteStockChecklist(int checklistId) async {
    try {
      final response = await ApiService.delete('$_baseEndpoint/checklists/$checklistId');
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de la checklist');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== ÉLÉMENTS DE CHECKLIST ==========

  /// Créer un nouvel élément de checklist
  static Future<StockCheckItem> createStockCheckItem(StockCheckItem item) async {
    try {
      final response = await ApiService.post('$_baseEndpoint/items', item.toJson());
      if (response.statusCode == 200) {
        return StockCheckItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de l\'élément');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir tous les éléments d'une checklist
  static Future<List<StockCheckItem>> getChecklistItems(int checklistId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/checklists/$checklistId/items');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockCheckItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments non vérifiés d'une checklist
  static Future<List<StockCheckItem>> getUncheckedItems(int checklistId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/checklists/$checklistId/items/unchecked');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockCheckItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments non vérifiés');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments critiques d'une checklist
  static Future<List<StockCheckItem>> getCriticalItems(int checklistId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/checklists/$checklistId/items/critical');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockCheckItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments critiques');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les éléments nécessitant un réapprovisionnement
  static Future<List<StockCheckItem>> getItemsNeedingRestock(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/items/restock');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => StockCheckItem.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des éléments à réapprovisionner');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Mettre à jour un élément de checklist
  static Future<StockCheckItem> updateStockCheckItem(int itemId, StockCheckItem item) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/items/$itemId', item.toJson());
      if (response.statusCode == 200) {
        return StockCheckItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la mise à jour de l\'élément');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Marquer un élément comme vérifié
  static Future<StockCheckItem> checkStockItem(int itemId, int stockCount, String notes) async {
    try {
      final response = await ApiService.put('$_baseEndpoint/items/$itemId/check', {
        'stockCount': stockCount,
        'notes': notes,
      });
      if (response.statusCode == 200) {
        return StockCheckItem.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la vérification de l\'élément');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Supprimer un élément de checklist
  static Future<void> deleteStockCheckItem(int itemId) async {
    try {
      final response = await ApiService.delete('$_baseEndpoint/items/$itemId');
      if (response.statusCode != 204) {
        throw Exception('Erreur lors de la suppression de l\'élément');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // ========== FONCTIONNALITÉS SPÉCIALES ==========

  /// Créer une checklist à partir des éléments de confort
  static Future<StockChecklist> createChecklistFromComfortItems(int childId, String checklistName, List<int> comfortItemIds) async {
    try {
      final response = await ApiService.post('$_baseEndpoint/children/$childId/checklists/from-comfort-items', {
        'name': checklistName,
        'comfortItemIds': comfortItemIds,
      });
      if (response.statusCode == 200) {
        return StockChecklist.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la création de la checklist à partir des éléments de confort');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  /// Obtenir les statistiques de stock d'un enfant
  static Future<StockStats> getStockStats(int childId) async {
    try {
      final response = await ApiService.get('$_baseEndpoint/children/$childId/stats');
      if (response.statusCode == 200) {
        return StockStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des statistiques de stock');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}







