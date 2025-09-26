import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admin_models.dart';
import 'api_service.dart';

class AdminService {

  // Statistiques d'administration
  Future<AdminStats> getAdminStats() async {
    try {
      final response = await ApiService.get('/admin/stats');
      if (response.statusCode == 200) {
        return AdminStats.fromJson(json.decode(response.body));
      } else {
        throw Exception('Erreur lors de la récupération des statistiques');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Vérifier les droits administrateur
  Future<bool> checkAdminAccess() async {
    try {
      final response = await ApiService.get('/admin/check-access');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Gestion des utilisateurs
  Future<List<AdminUser>> getAllUsers() async {
    try {
      final response = await ApiService.get('/admin/users');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => AdminUser.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des utilisateurs');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<AdminUser>> getParents() async {
    try {
      final response = await ApiService.get('/admin/users/parents');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => AdminUser.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des parents');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<List<AdminUser>> getProfessionals() async {
    try {
      final response = await ApiService.get('/admin/users/professionals');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => AdminUser.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des professionnels');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<String> manageUser(String email, String action, UserManagementRequest? request) async {
    try {
      final body = {
        'email': email,
        'action': action,
        if (request != null) ...request.toJson(),
      };

      final response = await ApiService.post('/admin/users/manage', body);
      if (response.statusCode == 200) {
        return json.decode(response.body)['message'] ?? 'Action effectuée avec succès';
      } else {
        final error = json.decode(response.body)['error'] ?? 'Erreur inconnue';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<AdminUser> createAdminUser(String email, String username, String password) async {
    try {
      final body = {
        'email': email,
        'username': username,
        'password': password,
      };

      final response = await ApiService.post('/admin/users/create-admin', body);
      if (response.statusCode == 200) {
        return AdminUser.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body)['error'] ?? 'Erreur inconnue';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  // Gestion de la base de connaissances RAG
  Future<List<KnowledgeBaseEntry>> getAllKnowledgeEntries() async {
    try {
      final response = await ApiService.get('/admin/knowledge');
      if (response.statusCode == 200) {
        final List<dynamic> entriesJson = json.decode(response.body);
        return entriesJson.map((json) => KnowledgeBaseEntry.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des connaissances');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<KnowledgeBaseEntry> addKnowledgeEntry(KnowledgeBaseEntry entry) async {
    try {
      final response = await ApiService.post('/admin/knowledge', entry.toJson());
      if (response.statusCode == 200) {
        return KnowledgeBaseEntry.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body)['error'] ?? 'Erreur inconnue';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<KnowledgeBaseEntry> updateKnowledgeEntry(int id, KnowledgeBaseEntry entry) async {
    try {
      final response = await ApiService.put('/admin/knowledge/$id', entry.toJson());
      if (response.statusCode == 200) {
        return KnowledgeBaseEntry.fromJson(json.decode(response.body));
      } else {
        final error = json.decode(response.body)['error'] ?? 'Erreur inconnue';
        throw Exception(error);
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }

  Future<bool> deleteKnowledgeEntry(int id) async {
    try {
      final response = await ApiService.delete('/admin/knowledge/$id');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Recherche d'utilisateurs
  Future<List<AdminUser>> searchUsers(String searchTerm) async {
    try {
      final response = await ApiService.get('/admin/users/search?term=$searchTerm');
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => AdminUser.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors de la recherche');
      }
    } catch (e) {
      throw Exception('Erreur: $e');
    }
  }
}
