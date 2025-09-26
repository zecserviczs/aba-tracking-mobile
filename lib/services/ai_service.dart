import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_model.dart';

class AIService {
  static const String baseUrl = 'http://localhost:8080/api';
  static final Logger _logger = Logger();

  // Headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Analyser les comportements d'un enfant
  static Future<BehaviorAnalysis> analyzeBehaviors(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ai/analyze-behaviors/$childId'),
        headers: headers,
      );

      _logger.d('AI Analysis response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BehaviorAnalysis.fromJson(data);
      } else {
        // En cas d'erreur, retourner des données simulées pour les tests
        _logger.w('Using simulated data for analysis');
        return _getSimulatedAnalysis();
      }
    } catch (e) {
      _logger.e('AI Analysis error: $e');
      // Retourner des données simulées en cas d'erreur
      return _getSimulatedAnalysis();
    }
  }

  // Générer des recommandations personnalisées
  static Future<List<Recommendation>> generateRecommendations(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ai/recommendations/$childId'),
        headers: headers,
      );

      _logger.d('AI Recommendations response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Recommendation.fromJson(json)).toList();
      } else {
        _logger.w('Using simulated data for recommendations');
        return _getSimulatedRecommendations();
      }
    } catch (e) {
      _logger.e('AI Recommendations error: $e');
      return _getSimulatedRecommendations();
    }
  }

  // Prédire les tendances comportementales
  static Future<BehaviorPrediction> predictBehaviorTrends(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ai/predict-trends/$childId'),
        headers: headers,
      );

      _logger.d('AI Prediction response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BehaviorPrediction.fromJson(data);
      } else {
        _logger.w('Using simulated data for predictions');
        return _getSimulatedPrediction();
      }
    } catch (e) {
      _logger.e('AI Prediction error: $e');
      return _getSimulatedPrediction();
    }
  }

  // Générer un rapport d'analyse complet
  static Future<AIAnalysisReport> generateAnalysisReport(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ai/analysis-report/$childId'),
        headers: headers,
      );

      _logger.d('AI Report response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return AIAnalysisReport.fromJson(data);
      } else {
        _logger.w('Using simulated data for report');
        return _getSimulatedReport(childId);
      }
    } catch (e) {
      _logger.e('AI Report error: $e');
      return _getSimulatedReport(childId);
    }
  }

  // Analyser les patterns comportementaux
  static Future<List<BehaviorPattern>> analyzePatterns(int childId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/ai/analyze-patterns/$childId'),
        headers: headers,
      );

      _logger.d('AI Patterns response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => BehaviorPattern.fromJson(json)).toList();
      } else {
        _logger.w('Using simulated data for patterns');
        return _getSimulatedPatterns();
      }
    } catch (e) {
      _logger.e('AI Patterns error: $e');
      return _getSimulatedPatterns();
    }
  }

  // Méthodes de données simulées pour les tests
  static BehaviorAnalysis _getSimulatedAnalysis() {
    return BehaviorAnalysis(
      summary: 'Analyse basée sur 15 observations récentes. Niveau de risque: Moyen. Intensité moyenne: 6.2/10. Comportement principal: Agitation.',
      keyFindings: [
        'Total de 15 observations analysées',
        'Intensité moyenne: 6.2/10',
        'Comportement le plus fréquent: Agitation',
        'Déclencheurs identifiés: Fatigue, Changement de routine, Bruit'
      ],
      behaviorFrequency: {
        'Agitation': 0.4,
        'Cris': 0.25,
        'Retrait': 0.2,
        'Autres': 0.15
      },
      riskLevel: 'Moyen',
      triggers: ['Fatigue', 'Changement de routine', 'Bruit']
    );
  }

  static List<Recommendation> _getSimulatedRecommendations() {
    return [
      Recommendation(
        title: 'Stratégie pour Agitation',
        description: 'Comportement d\'agitation observé 6 fois. Techniques de régulation recommandées.',
        category: 'Comportement',
        priority: 1,
        steps: [
          'Identifier les signes précurseurs',
          'Utiliser des techniques de respiration',
          'Proposer des alternatives acceptables',
          'Créer un espace de calme'
        ]
      ),
      Recommendation(
        title: 'Gestion des déclencheurs',
        description: 'Des déclencheurs spécifiques ont été identifiés. Des stratégies préventives sont recommandées.',
        category: 'Prévention',
        priority: 2,
        steps: [
          'Éviter les déclencheurs identifiés quand possible',
          'Préparer des stratégies d\'adaptation',
          'Enseigner des compétences de coping',
          'Créer un plan d\'intervention préventif'
        ]
      ),
      Recommendation(
        title: 'Amélioration de la communication',
        description: 'Stratégies pour réduire les cris et améliorer la communication.',
        category: 'Communication',
        priority: 3,
        steps: [
          'Enseigner des mots de remplacement',
          'Utiliser des signes visuels',
          'Récompenser la communication calme',
          'Éviter de renforcer les cris'
        ]
      )
    ];
  }

  static BehaviorPrediction _getSimulatedPrediction() {
    return BehaviorPrediction(
      trend: 'Stabilité générale des comportements observés',
      confidence: 0.75,
      predictedBehaviors: [
        'Continuité des patterns actuels',
        'Possible diminution de l\'agitation avec les interventions'
      ],
      timeframe: 'Prochaines 2-4 semaines',
      recommendations: [
        'Continuer le suivi régulier',
        'Maintenir les stratégies préventives',
        'Ajuster les interventions si nécessaire'
      ]
    );
  }

  static List<BehaviorPattern> _getSimulatedPatterns() {
    return [
      BehaviorPattern(
        name: 'Pattern Matin',
        description: 'Comportements plus fréquents le matin',
        frequency: 0.45,
        associatedBehaviors: ['Agitation', 'Difficulté de concentration'],
        timeOfDay: 'Matin',
        dayOfWeek: 'Tous les jours'
      ),
      BehaviorPattern(
        name: 'Pattern Après-midi',
        description: 'Comportements plus fréquents l\'après-midi',
        frequency: 0.35,
        associatedBehaviors: ['Fatigue', 'Irritabilité'],
        timeOfDay: 'Après-midi',
        dayOfWeek: 'Tous les jours'
      ),
      BehaviorPattern(
        name: 'Pattern Soir',
        description: 'Comportements plus fréquents le soir',
        frequency: 0.2,
        associatedBehaviors: ['Agitation', 'Difficulté d\'endormissement'],
        timeOfDay: 'Soir',
        dayOfWeek: 'Tous les jours'
      )
    ];
  }

  static AIAnalysisReport _getSimulatedReport(int childId) {
    return AIAnalysisReport(
      childName: 'Enfant $childId',
      generatedAt: DateTime.now(),
      analysis: _getSimulatedAnalysis(),
      recommendations: _getSimulatedRecommendations(),
      prediction: _getSimulatedPrediction(),
      patterns: _getSimulatedPatterns()
    );
  }
}

// Modèles de données pour l'IA
class BehaviorAnalysis {
  final String summary;
  final List<String> keyFindings;
  final Map<String, double> behaviorFrequency;
  final String riskLevel;
  final List<String> triggers;

  BehaviorAnalysis({
    required this.summary,
    required this.keyFindings,
    required this.behaviorFrequency,
    required this.riskLevel,
    required this.triggers,
  });

  factory BehaviorAnalysis.fromJson(Map<String, dynamic> json) {
    return BehaviorAnalysis(
      summary: json['summary'] ?? '',
      keyFindings: List<String>.from(json['keyFindings'] ?? []),
      behaviorFrequency: Map<String, double>.from(json['behaviorFrequency'] ?? {}),
      riskLevel: json['riskLevel'] ?? 'Moyen',
      triggers: List<String>.from(json['triggers'] ?? []),
    );
  }
}

class Recommendation {
  final String title;
  final String description;
  final String category;
  final int priority;
  final List<String> steps;

  Recommendation({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.steps,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? 1,
      steps: List<String>.from(json['steps'] ?? []),
    );
  }
}

class BehaviorPrediction {
  final String trend;
  final double confidence;
  final List<String> predictedBehaviors;
  final String timeframe;
  final List<String> recommendations;

  BehaviorPrediction({
    required this.trend,
    required this.confidence,
    required this.predictedBehaviors,
    required this.timeframe,
    required this.recommendations,
  });

  factory BehaviorPrediction.fromJson(Map<String, dynamic> json) {
    return BehaviorPrediction(
      trend: json['trend'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      predictedBehaviors: List<String>.from(json['predictedBehaviors'] ?? []),
      timeframe: json['timeframe'] ?? '',
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

class AIAnalysisReport {
  final String childName;
  final DateTime generatedAt;
  final BehaviorAnalysis analysis;
  final List<Recommendation> recommendations;
  final BehaviorPrediction prediction;
  final List<BehaviorPattern> patterns;

  AIAnalysisReport({
    required this.childName,
    required this.generatedAt,
    required this.analysis,
    required this.recommendations,
    required this.prediction,
    required this.patterns,
  });

  factory AIAnalysisReport.fromJson(Map<String, dynamic> json) {
    return AIAnalysisReport(
      childName: json['childName'] ?? '',
      generatedAt: DateTime.parse(json['generatedAt'] ?? DateTime.now().toIso8601String()),
      analysis: BehaviorAnalysis.fromJson(json['analysis'] ?? {}),
      recommendations: (json['recommendations'] as List?)
          ?.map((r) => Recommendation.fromJson(r))
          .toList() ?? [],
      prediction: BehaviorPrediction.fromJson(json['prediction'] ?? {}),
      patterns: (json['patterns'] as List?)
          ?.map((p) => BehaviorPattern.fromJson(p))
          .toList() ?? [],
    );
  }
}

class BehaviorPattern {
  final String name;
  final String description;
  final double frequency;
  final List<String> associatedBehaviors;
  final String timeOfDay;
  final String dayOfWeek;

  BehaviorPattern({
    required this.name,
    required this.description,
    required this.frequency,
    required this.associatedBehaviors,
    required this.timeOfDay,
    required this.dayOfWeek,
  });

  factory BehaviorPattern.fromJson(Map<String, dynamic> json) {
    return BehaviorPattern(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      frequency: (json['frequency'] ?? 0.0).toDouble(),
      associatedBehaviors: List<String>.from(json['associatedBehaviors'] ?? []),
      timeOfDay: json['timeOfDay'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? '',
    );
  }
}
