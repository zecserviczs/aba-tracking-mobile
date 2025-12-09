import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/api_service.dart';
import 'dart:convert';

class ParentResource {
  final int id;
  final String title;
  final String type;
  final String category;
  final String description;
  final String? url;
  final String? duration;
  final bool published;

  ParentResource({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.description,
    this.url,
    this.duration,
    this.published = true,
  });

  factory ParentResource.fromJson(Map<String, dynamic> json) {
    return ParentResource(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      url: json['url'],
      duration: json['duration'],
      published: json['published'] ?? true,
    );
  }
}

class AdminResourcesScreen extends ConsumerStatefulWidget {
  const AdminResourcesScreen({super.key});

  @override
  ConsumerState<AdminResourcesScreen> createState() => _AdminResourcesScreenState();
}

class _AdminResourcesScreenState extends ConsumerState<AdminResourcesScreen> {
  List<ParentResource> _resources = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/admin/parent-resources');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _resources = data.map((json) => ParentResource.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Erreur lors du chargement');
      }
    } catch (e) {
      setState(() {
        _error = 'Impossible de charger les ressources: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteResource(ParentResource resource) async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la ressource'),
        content: Text('Supprimer la ressource « ${resource.title} » ?'),
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
        await ApiService.delete('/admin/parent-resources/${resource.id}');
        setState(() {
          _successMessage = 'Ressource supprimée avec succès';
        });
        _loadResources();
      } catch (e) {
        setState(() {
          _error = 'Impossible de supprimer la ressource: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Ressources'),
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
                      child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
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
                      child: Text(_successMessage!, style: TextStyle(color: Colors.green.shade700)),
                    ),
                  if (_resources.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Aucune ressource disponible'),
                      ),
                    )
                  else
                    ..._resources.map((resource) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Type: ${resource.type}'),
                              Text('Catégorie: ${resource.category}'),
                              if (resource.description.isNotEmpty)
                                Text(resource.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteResource(resource),
                          ),
                          onTap: resource.url != null
                              ? () async {
                                  final uri = Uri.parse(resource.url!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                }
                              : null,
                        ),
                      );
                    }),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Création de ressource - Fonctionnalité à venir')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


