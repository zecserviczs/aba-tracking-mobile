import 'package:flutter/material.dart';
import '../../models/planning_models.dart';
import '../../services/discomfort_service.dart';

class DiscomfortScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const DiscomfortScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<DiscomfortScreen> createState() => _DiscomfortScreenState();
}

class _DiscomfortScreenState extends State<DiscomfortScreen> {
  List<DiscomfortItem> discomforts = [];
  bool isLoading = true;
  int totalDiscomforts = 0;
  int criticalTriggers = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      // Pour l'instant, données simulées car le backend n'existe pas encore
      await Future.delayed(Duration(seconds: 1));

      setState(() {
        discomforts = [
          DiscomfortItem(
            id: 1,
            title: 'Bruit fort soudain',
            description: 'L\'enfant réagit violemment aux bruits inattendus',
            severity: 'high',
            category: 'Sensoriel',
            triggers: ['Sirènes', 'Musique forte', 'Cris'],
            lastOccurrence: DateTime.now().subtract(Duration(days: 1)),
            frequency: 3,
          ),
          DiscomfortItem(
            id: 2,
            title: 'Changement de routine',
            description: 'Difficultés lors de modifications imprévues',
            severity: 'critical',
            category: 'Routine',
            triggers: [
              'Annulation',
              'Changement d\'horaire',
              'Visite surprise'
            ],
            lastOccurrence: DateTime.now().subtract(Duration(days: 2)),
            frequency: 5,
          ),
        ];
        totalDiscomforts = discomforts.length;
        criticalTriggers =
            discomforts.where((d) => d.severity == 'critical').length;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inconforts - ${widget.childName}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Statistiques
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Inconforts',
                              totalDiscomforts.toString(),
                              Colors.orange,
                              Icons.warning,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Critiques',
                              criticalTriggers.toString(),
                              Colors.red,
                              Icons.priority_high,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Liste des inconforts
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inconforts identifiés',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          ...discomforts
                              .map((item) => _buildDiscomfortCard(item)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDiscomfortDialog,
        backgroundColor: Colors.red[700],
        icon: Icon(Icons.add),
        label: Text('Ajouter'),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscomfortCard(DiscomfortItem item) {
    final severityColor = _getSeverityColor(item.severity);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _showDiscomfortDetails(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_getSeverityIcon(item.severity), color: severityColor),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildSeverityBadge(item.severity),
                ],
              ),
              SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              if (item.triggers.isNotEmpty) ...[
                SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.triggers.map((trigger) {
                    return Chip(
                      label: Text(
                        trigger,
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: Colors.red[400],
                      padding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    final color = _getSeverityColor(severity);
    final label = _getSeverityLabel(severity);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red[900]!;
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange[700]!;
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.priority_high;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity) {
      case 'critical':
        return 'CRITIQUE';
      case 'high':
        return 'ÉLEVÉ';
      case 'medium':
        return 'MODÉRÉ';
      case 'low':
        return 'FAIBLE';
      default:
        return severity.toUpperCase();
    }
  }

  void _showDiscomfortDetails(DiscomfortItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.description),
              SizedBox(height: 16),
              Text('Catégorie: ${item.category}',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text('Fréquence: ${item.frequency}/semaine'),
              if (item.triggers.isNotEmpty) ...[
                SizedBox(height: 12),
                Text('Déclencheurs:',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ...item.triggers.map((t) => Text('• $t')),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditDiscomfortDialog(item);
            },
            child: Text('Modifier'),
          ),
        ],
      ),
    );
  }

  void _showAddDiscomfortDialog() {
    _showDiscomfortFormDialog(null);
  }

  void _showEditDiscomfortDialog(DiscomfortItem item) {
    _showDiscomfortFormDialog(item);
  }

  void _showDiscomfortFormDialog(DiscomfortItem? existingItem) {
    final titleController =
        TextEditingController(text: existingItem?.title ?? '');
    final descController =
        TextEditingController(text: existingItem?.description ?? '');
    String severity = existingItem?.severity ?? 'medium';
    String category = existingItem?.category ?? 'Sensoriel';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingItem == null
            ? 'Nouvel inconfort'
            : 'Modifier l\'inconfort'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Titre *'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: severity,
                decoration: InputDecoration(labelText: 'Sévérité'),
                items: [
                  DropdownMenuItem(value: 'low', child: Text('Faible')),
                  DropdownMenuItem(value: 'medium', child: Text('Modéré')),
                  DropdownMenuItem(value: 'high', child: Text('Élevé')),
                  DropdownMenuItem(value: 'critical', child: Text('Critique')),
                ],
                onChanged: (value) {
                  severity = value!;
                },
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: [
                  DropdownMenuItem(
                      value: 'Sensoriel', child: Text('Sensoriel')),
                  DropdownMenuItem(value: 'Routine', child: Text('Routine')),
                  DropdownMenuItem(value: 'Visuel', child: Text('Visuel')),
                  DropdownMenuItem(value: 'Tactile', child: Text('Tactile')),
                  DropdownMenuItem(value: 'Social', child: Text('Social')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (value) {
                  category = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Le titre est obligatoire')),
                );
                return;
              }

              Navigator.pop(context);

              // TODO: Sauvegarder via API
              setState(() {
                if (existingItem == null) {
                  discomforts.add(
                    DiscomfortItem(
                      id: discomforts.length + 1,
                      title: titleController.text,
                      description: descController.text,
                      severity: severity,
                      category: category,
                      triggers: [],
                      lastOccurrence: DateTime.now(),
                      frequency: 1,
                    ),
                  );
                  totalDiscomforts++;
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(existingItem == null
                      ? 'Inconfort ajouté'
                      : 'Inconfort modifié'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
            ),
            child: Text(existingItem == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }
}
