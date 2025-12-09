import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/child_model.dart';
import '../../services/api_service.dart';

class CenterDashboardScreen extends ConsumerStatefulWidget {
  const CenterDashboardScreen({super.key});

  @override
  ConsumerState<CenterDashboardScreen> createState() => _CenterDashboardScreenState();
}

class _CenterDashboardScreenState extends ConsumerState<CenterDashboardScreen> {
  List<Child> _children = [];
  int? _selectedChildId;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _activitiesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _moodController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _activitiesController.dispose();
    _notesController.dispose();
    _moodController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/center/my-children');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _children = data.map((json) => Child.fromJson(json)).toList();
          if (_children.isNotEmpty) {
            _selectedChildId = _children.first.id;
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement des enfants');
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les enfants autorisés: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSummary() async {
    if (_selectedChildId == null) {
      setState(() {
        _error = 'Choisissez un enfant';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
      _successMessage = null;
    });

    try {
      await ApiService.post(
        '/center/children/$_selectedChildId/summaries',
        {
          'day': _selectedDate.toIso8601String().substring(0, 10),
          'activities': _activitiesController.text,
          'notes': _notesController.text,
          'mood': _moodController.text,
        },
      );

      setState(() {
        _successMessage = 'Résumé enregistré';
        _activitiesController.clear();
        _notesController.clear();
        _moodController.clear();
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'enregistrement: $e';
        _isSaving = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centre – Saisie de résumé'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sélectionnez l\'enfant et saisissez le résumé du jour.',
                            style: TextStyle(color: Colors.blue.shade900),
                          ),
                        ),
                      ],
                    ),
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
                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: _selectDate,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _activitiesController,
                            decoration: const InputDecoration(
                              labelText: 'Activités',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _moodController,
                            decoration: const InputDecoration(
                              labelText: 'Humeur',
                              hintText: 'Calme / Agité / Fatigué…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _isSaving ? null : _saveSummary,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

