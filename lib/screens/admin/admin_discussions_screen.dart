import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import 'dart:convert';

class DiscussionSpace {
  final int id;
  final String title;
  final String description;
  final String? tags;
  final bool published;
  final int subscriberCount;

  DiscussionSpace({
    required this.id,
    required this.title,
    required this.description,
    this.tags,
    this.published = true,
    this.subscriberCount = 0,
  });

  factory DiscussionSpace.fromJson(Map<String, dynamic> json) {
    return DiscussionSpace(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: json['tags'],
      published: json['published'] ?? true,
      subscriberCount: json['subscriberCount'] ?? 0,
    );
  }
}

class AdminDiscussionsScreen extends ConsumerStatefulWidget {
  const AdminDiscussionsScreen({super.key});

  @override
  ConsumerState<AdminDiscussionsScreen> createState() => _AdminDiscussionsScreenState();
}

class _AdminDiscussionsScreenState extends ConsumerState<AdminDiscussionsScreen> {
  List<DiscussionSpace> _spaces = [];
  DiscussionSpace? _selectedSpace;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadSpaces();
  }

  Future<void> _loadSpaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/admin/parent-discussions/spaces');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _spaces = data.map((json) => DiscussionSpace.fromJson(json)).toList();
          if (_spaces.isNotEmpty && _selectedSpace == null) {
            _selectedSpace = _spaces.first;
          }
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement');
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les espaces: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSpace(DiscussionSpace space) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'espace'),
        content: Text('Supprimer l\'espace « ${space.title} » ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.delete('/admin/parent-discussions/spaces/${space.id}');
        setState(() {
          _successMessage = 'Espace supprimé avec succès';
          if (_selectedSpace?.id == space.id) {
            _selectedSpace = null;
          }
        });
        _loadSpaces();
      } catch (e) {
        setState(() {
          _error = 'Impossible de supprimer l\'espace: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Discussions'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Liste des espaces
                Container(
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.red.shade50,
                          child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                        ),
                      if (_successMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          color: Colors.green.shade50,
                          child: Text(_successMessage!, style: TextStyle(color: Colors.green.shade700)),
                        ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _spaces.length,
                          itemBuilder: (context, index) {
                            final space = _spaces[index];
                            final isSelected = _selectedSpace?.id == space.id;
                            return ListTile(
                              selected: isSelected,
                              title: Text(space.title),
                              subtitle: Text('${space.subscriberCount} abonnés'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _deleteSpace(space),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedSpace = space;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Détails de l'espace sélectionné
                Expanded(
                  child: _selectedSpace == null
                      ? const Center(child: Text('Sélectionnez un espace'))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _selectedSpace!.title,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(_selectedSpace!.description),
                              if (_selectedSpace!.tags != null) ...[
                                const SizedBox(height: 8),
                                Text('Tags: ${_selectedSpace!.tags}'),
                              ],
                              const SizedBox(height: 16),
                              Text(
                                '${_selectedSpace!.subscriberCount} abonnés',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Création d\'espace - Fonctionnalité à venir')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


