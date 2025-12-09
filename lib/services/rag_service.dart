import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rag_models.dart';

class RAGService {
  static const String baseUrl = 'http://localhost:8080/api/rag';
  
  static Future<RAGResponse> queryRAG(RAGQuery query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(query.toJson()),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return RAGResponse.fromJson(data);
      } else {
        throw Exception('Erreur lors de la requête RAG: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion au service RAG: $e');
    }
  }
  
  static Future<List<Document>> getAllDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
  
  static Future<List<Document>> getDocumentsByType(String type) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Token d\'authentification manquant');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/documents/type/$type'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des documents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
  
  static Future<Map<String, String>> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data.cast<String, String>();
      } else {
        throw Exception('Service RAG non disponible: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion au service RAG: $e');
    }
  }
}








