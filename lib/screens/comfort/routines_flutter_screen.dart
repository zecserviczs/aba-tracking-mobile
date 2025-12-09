import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoutineModel {
  int? id;
  String name;
  String description;
  String type;
  String status;
  String frequency;
  int duration;
  List<String> steps;
  List<String> timings;

  RoutineModel({
    this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.status,
    required this.frequency,
    required this.duration,
    required this.steps,
    required this.timings,
  });
}

class RoutinesFlutterScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const RoutinesFlutterScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<RoutinesFlutterScreen> createState() => _RoutinesFlutterScreenState();
}

class _RoutinesFlutterScreenState extends State<RoutinesFlutterScreen> {
  List<RoutineModel> routines = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      routines = [
        RoutineModel(
          id: 1,
          name: 'Routine du matin',
          description: 'Séquence apaisante pour commencer la journée',
          type: 'Matin',
          status: 'active',
          frequency: 'Quotidienne',
          duration: 30,
          steps: [
            'Réveil en douceur',
            'Toilette calme',
            'Petit-déjeuner',
            'Préparation école'
          ],
          timings: ['07:00', '07:30', '08:00'],
        ),
        RoutineModel(
          id: 2,
          name: 'Routine du soir',
          description: 'Détente avant le coucher',
          type: 'Soir',
          status: 'active',
          frequency: 'Quotidienne',
          duration: 45,
          steps: [
            'Arrêt activités',
            'Bain relaxant',
            'Histoire',
            'Câlin et bonne nuit'
          ],
          timings: ['19:00', '19:30', '20:00', '20:30'],
        ),
      ];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/children/${widget.childId}/comfort'),
        ),
        title: Text('Routines - ${widget.childName}'),
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
            : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: routines.length,
                itemBuilder: (context, index) {
                  return _buildRoutineCard(routines[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddRoutineDialog,
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add),
        label: Text('Nouvelle routine'),
      ),
    );
  }

  Widget _buildRoutineCard(RoutineModel routine) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[300]!, width: 2),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.schedule, color: Colors.white),
        ),
        title: Text(
          routine.name,
          style:
              TextStyle(fontWeight: FontWeight.w600, color: Colors.green[900]),
        ),
        subtitle: Text(routine.description),
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoChip(
                        Icons.category, routine.type, Colors.green[600]!),
                    SizedBox(width: 8),
                    _buildInfoChip(
                        Icons.repeat, routine.frequency, Colors.blue[600]!),
                    SizedBox(width: 8),
                    _buildInfoChip(Icons.schedule, '${routine.duration}min',
                        Colors.orange[600]!),
                  ],
                ),
                SizedBox(height: 16),
                Text('Étapes:', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                ...routine.steps.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }).toList(),
                if (routine.timings.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Horaires:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: routine.timings.map((time) {
                      return Chip(
                        label: Text(time,
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.green[600],
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Modifier'),
                      onPressed: () => _showEditRoutineDialog(routine),
                    ),
                    SizedBox(width: 8),
                    TextButton.icon(
                      icon: Icon(Icons.delete, size: 18, color: Colors.red),
                      label: Text('Supprimer',
                          style: TextStyle(color: Colors.red)),
                      onPressed: () => _deleteRoutine(routine),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 11)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showAddRoutineDialog() {
    _showRoutineFormDialog(null);
  }

  void _showEditRoutineDialog(RoutineModel routine) {
    _showRoutineFormDialog(routine);
  }

  void _showRoutineFormDialog(RoutineModel? existingRoutine) {
    final nameController =
        TextEditingController(text: existingRoutine?.name ?? '');
    final descController =
        TextEditingController(text: existingRoutine?.description ?? '');
    String type = existingRoutine?.type ?? 'Matin';
    String frequency = existingRoutine?.frequency ?? 'Quotidienne';
    int duration = existingRoutine?.duration ?? 30;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingRoutine == null
            ? 'Nouvelle routine'
            : 'Modifier la routine'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom *'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: InputDecoration(labelText: 'Type'),
                items: [
                  'Matin',
                  'Midi',
                  'Après-midi',
                  'Soir',
                  'Transition',
                  'Général'
                ]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => type = value!,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: InputDecoration(labelText: 'Fréquence'),
                items: ['Quotidienne', 'Hebdomadaire', 'Selon besoin']
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (value) => frequency = value!,
              ),
              SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(labelText: 'Durée (minutes)'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: duration.toString()),
                onChanged: (value) => duration = int.tryParse(value) ?? 30,
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
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Le nom est obligatoire')),
                );
                return;
              }

              Navigator.pop(context);

              setState(() {
                if (existingRoutine == null) {
                  routines.add(
                    RoutineModel(
                      id: routines.length + 1,
                      name: nameController.text,
                      description: descController.text,
                      type: type,
                      status: 'active',
                      frequency: frequency,
                      duration: duration,
                      steps: ['Étape 1', 'Étape 2'],
                      timings: [],
                    ),
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(existingRoutine == null
                      ? 'Routine ajoutée'
                      : 'Routine modifiée'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: Text(existingRoutine == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteRoutine(RoutineModel routine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la routine'),
        content: Text('Voulez-vous vraiment supprimer "${routine.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                routines.remove(routine);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Routine supprimée'),
                    backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
