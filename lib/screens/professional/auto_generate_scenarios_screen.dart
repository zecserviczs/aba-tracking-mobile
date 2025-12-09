import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/child_model.dart';
import '../../models/social_scenario_models.dart';
import '../../services/api_service.dart';

class AutoGenerateScenariosScreen extends ConsumerStatefulWidget {
  const AutoGenerateScenariosScreen({super.key});

  @override
  ConsumerState<AutoGenerateScenariosScreen> createState() => _AutoGenerateScenariosScreenState();
}

class _AutoGenerateScenariosScreenState extends ConsumerState<AutoGenerateScenariosScreen> {
  List<Child> _children = [];
  List<ScenarioGenerationContext> _contexts = [];
  
  int? _selectedChildId;
  String _selectedContextCode = 'DAILY_ROUTINE';
  int _scenariosCount = 5;
  
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  String? _successMessage;
  List<SocialScenarioModel> _generatedScenarios = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final children = await ApiService.getAuthorizedChildren(userType: 'professional');
      final contexts = await ApiService.getScenarioGenerationContexts();
      
      setState(() {
        _children = children;
        _contexts = contexts;
        if (children.length == 1) {
          _selectedChildId = children.first.id;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _generateScenarios() async {
    if (_selectedChildId == null) {
      setState(() {
        _error = 'Veuillez sélectionner un enfant';
      });
      return;
    }

    if (_scenariosCount < 1 || _scenariosCount > 10) {
      setState(() {
        _error = 'Le nombre de scénarios doit être compris entre 1 et 10';
      });
      return;
    }

    setState(() {
      _isGenerating = true;
      _error = null;
      _successMessage = null;
      _generatedScenarios = [];
    });

    try {
      final scenarios = await ApiService.autoGenerateScenarios(
        childId: _selectedChildId!,
        contextCode: _selectedContextCode,
        count: _scenariosCount,
      );

      setState(() {
        _generatedScenarios = scenarios;
        _successMessage = '${scenarios.length} scénario(s) généré(s) avec succès';
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la génération: $e';
        _isGenerating = false;
      });
    }
  }

  String _getContextDescription() {
    final context = _contexts.firstWhere(
      (c) => c.code == _selectedContextCode,
      orElse: () => ScenarioGenerationContext(code: '', label: '', description: ''),
    );
    final description = context.description ?? '';
    return description.isNotEmpty
        ? description
        : 'Choisissez un contexte pour adapter les scénarios à la situation de l\'enfant.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Génération automatique de scénarios'),
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
                  if (_successMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: Colors.green.shade700),
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
                            'Configuration',
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
                          DropdownButtonFormField<String>(
                            value: _selectedContextCode,
                            decoration: const InputDecoration(
                              labelText: 'Contexte',
                              border: OutlineInputBorder(),
                            ),
                            items: _contexts.map((context) {
                              return DropdownMenuItem<String>(
                                value: context.code,
                                child: Text(context.label),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedContextCode = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _getContextDescription(),
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _scenariosCount.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Nombre de scénarios (1-10)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final count = int.tryParse(value);
                              if (count != null && count >= 1 && count <= 10) {
                                setState(() {
                                  _scenariosCount = count;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isGenerating ? null : _generateScenarios,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isGenerating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Générer les scénarios'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_generatedScenarios.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Scénarios générés',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._generatedScenarios.map((scenario) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            scenario.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            scenario.description ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            context.go('/social-scenarios');
                          },
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
    );
  }
}

