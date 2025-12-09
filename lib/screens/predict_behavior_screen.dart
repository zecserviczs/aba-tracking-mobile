import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/child_model.dart';
import '../services/api_service.dart';

class BehaviorPrediction {
  final int riskScore;
  final List<String> likelyTriggers;
  final List<String> suggestedStrategies;
  final List<String> recommendedSocialStories;
  final String? rationale;
  final String generatedAt;

  BehaviorPrediction({
    required this.riskScore,
    required this.likelyTriggers,
    required this.suggestedStrategies,
    required this.recommendedSocialStories,
    this.rationale,
    required this.generatedAt,
  });

  factory BehaviorPrediction.fromJson(Map<String, dynamic> json) {
    return BehaviorPrediction(
      riskScore: json['riskScore'] ?? 0,
      likelyTriggers: List<String>.from(json['likelyTriggers'] ?? []),
      suggestedStrategies: List<String>.from(json['suggestedStrategies'] ?? []),
      recommendedSocialStories:
          List<String>.from(json['recommendedSocialStories'] ?? []),
      rationale: json['rationale'],
      generatedAt: json['generatedAt'] ?? '',
    );
  }
}

class PredictBehaviorScreen extends ConsumerStatefulWidget {
  const PredictBehaviorScreen({super.key});

  @override
  ConsumerState<PredictBehaviorScreen> createState() => _PredictBehaviorScreenState();
}

class _PredictBehaviorScreenState extends ConsumerState<PredictBehaviorScreen> {
  List<Child> _children = [];
  int? _selectedChildId;

  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isPredicting = false;
  String? _error;
  BehaviorPrediction? _predictionResult;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _activityController.dispose();
    _sleepQualityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final children = await ApiService.getAuthorizedChildren(userType: 'parent');
      setState(() {
        _children = children;
        if (children.isNotEmpty) {
          _selectedChildId = children.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des enfants: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _predictBehavior() async {
    if (_selectedChildId == null) {
      setState(() {
        _error = 'Veuillez sélectionner un enfant';
      });
      return;
    }

    setState(() {
      _isPredicting = true;
      _error = null;
      _predictionResult = null;
    });

    try {
      final response = await ApiService.post(
        '/ai/predict-behavior',
        {
          'childId': _selectedChildId,
          'context': {
            'location': _locationController.text,
            'activity': _activityController.text,
            'sleepQuality': _sleepQualityController.text,
            'notes': _notesController.text,
          },
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = BehaviorPrediction.fromJson(data);
          _isPredicting = false;
        });
      } else {
        throw Exception('Erreur lors de la prédiction');
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la prédiction: $e';
        _isPredicting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤖 Prévoir le comportement'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Outils IA disponibles
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          child: InkWell(
                            onTap: () => context.go('/rag-chat'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(Icons.psychology, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Assistant IA ABA',
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Chat avec l\'assistant intelligent',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          child: InkWell(
                            onTap: () => context.go('/ai-analysis'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  const Icon(Icons.analytics, size: 48),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Analyse IA',
                                    style: Theme.of(context).textTheme.titleMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Analyser les observations',
                                    style: Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Contexte de prédiction',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _selectedChildId,
                            decoration: const InputDecoration(
                              labelText: 'Enfant',
                              border: OutlineInputBorder(),
                            ),
                            items: _children.map((child) {
                              return DropdownMenuItem<int>(
                                value: child.id,
                                child: Text('${child.name} (${child.age} ans)'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedChildId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'Lieu',
                              hintText: 'Classe, maison, centre…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _activityController,
                            decoration: const InputDecoration(
                              labelText: 'Activité',
                              hintText: 'Transition, repas…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _sleepQualityController,
                            decoration: const InputDecoration(
                              labelText: 'Qualité du sommeil',
                              hintText: 'Bonne / moyenne / médiocre',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              hintText:
                                  'Infos utiles (douleur, bruit, changement de routine…)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed:
                                _isPredicting || _children.isEmpty ? null : _predictBehavior,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isPredicting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Lancer la prédiction'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_predictionResult != null) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Résultat',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text('Risque (0–100): ${_predictionResult!.riskScore}'),
                            if (_predictionResult!.likelyTriggers.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Déclencheurs probables:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._predictionResult!.likelyTriggers.map((trigger) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                                  child: Text('• $trigger'),
                                );
                              }),
                            ],
                            if (_predictionResult!.suggestedStrategies.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Stratégies suggérées:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._predictionResult!.suggestedStrategies.map((strategy) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                                  child: Text('• $strategy'),
                                );
                              }),
                            ],
                            if (_predictionResult!.recommendedSocialStories.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'Scénarios sociaux conseillés:',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ..._predictionResult!.recommendedSocialStories.map((story) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                                  child: Text('• $story'),
                                );
                              }),
                            ],
                            if (_predictionResult!.rationale != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _predictionResult!.rationale!,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Généré le ${_predictionResult!.generatedAt}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

