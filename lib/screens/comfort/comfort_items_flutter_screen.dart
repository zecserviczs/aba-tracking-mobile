import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ComfortItemModel {
  int? id;
  String name;
  String description;
  String category;
  String importance;
  String availability;
  String location;
  String notes;

  ComfortItemModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.importance,
    required this.availability,
    required this.location,
    required this.notes,
  });
}

class ComfortItemsFlutterScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ComfortItemsFlutterScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ComfortItemsFlutterScreen> createState() =>
      _ComfortItemsFlutterScreenState();
}

class _ComfortItemsFlutterScreenState extends State<ComfortItemsFlutterScreen> {
  List<ComfortItemModel> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    setState(() {
      items = [
        ComfortItemModel(
          id: 1,
          name: 'Doudou lapin',
          description: 'Peluche lapin bleu, présence rassurante',
          category: 'Objet sensoriel',
          importance: 'essentiel',
          availability: 'disponible',
          location: 'Chambre',
          notes: 'Toujours avec lui pour dormir',
        ),
        ComfortItemModel(
          id: 2,
          name: 'Casque anti-bruit',
          description: 'Casque bleu pour environnements bruyants',
          category: 'Objet sensoriel',
          importance: 'essentiel',
          availability: 'disponible',
          location: 'Sac à dos',
          notes: 'Indispensable dans les lieux publics',
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
        title: Text('Éléments de confort - ${widget.childName}'),
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildItemCard(items[index]);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        backgroundColor: Colors.green[700],
        icon: Icon(Icons.add),
        label: Text('Nouvel élément'),
      ),
    );
  }

  Widget _buildItemCard(ComfortItemModel item) {
    final importanceColor = _getImportanceColor(item.importance);
    final availabilityColor = _getAvailabilityColor(item.availability);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green[300]!, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[900],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green[300]!),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(fontSize: 11, color: Colors.green[700]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _buildBadge(
                  _getImportanceLabel(item.importance),
                  importanceColor,
                ),
                SizedBox(width: 8),
                _buildBadge(
                  _getAvailabilityLabel(item.availability),
                  availabilityColor,
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(item.description, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green[600]),
                SizedBox(width: 4),
                Text(item.location, style: TextStyle(fontSize: 13)),
              ],
            ),
            if (item.notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, size: 16, color: Colors.green[700]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.notes,
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.edit, size: 16),
                  label: Text('Modifier'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green[700],
                    side: BorderSide(color: Colors.green[700]!),
                  ),
                  onPressed: () => _showEditItemDialog(item),
                ),
                SizedBox(width: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.delete, size: 16),
                  label: Text('Supprimer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red),
                  ),
                  onPressed: () => _deleteItem(item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
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

  Color _getImportanceColor(String importance) {
    switch (importance) {
      case 'essentiel':
        return Colors.red[700]!;
      case 'important':
        return Colors.orange[700]!;
      case 'modéré':
        return Colors.blue[700]!;
      case 'optionnel':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  String _getImportanceLabel(String importance) {
    switch (importance) {
      case 'essentiel':
        return 'ESSENTIEL';
      case 'important':
        return 'IMPORTANT';
      case 'modéré':
        return 'MODÉRÉ';
      case 'optionnel':
        return 'OPTIONNEL';
      default:
        return importance.toUpperCase();
    }
  }

  Color _getAvailabilityColor(String availability) {
    switch (availability) {
      case 'disponible':
        return Colors.green[700]!;
      case 'indisponible':
        return Colors.red[700]!;
      case 'à remplacer':
        return Colors.orange[700]!;
      default:
        return Colors.grey;
    }
  }

  String _getAvailabilityLabel(String availability) {
    switch (availability) {
      case 'disponible':
        return 'DISPONIBLE';
      case 'indisponible':
        return 'INDISPONIBLE';
      case 'à remplacer':
        return 'À REMPLACER';
      default:
        return availability.toUpperCase();
    }
  }

  void _showAddItemDialog() {
    _showItemFormDialog(null);
  }

  void _showEditItemDialog(ComfortItemModel item) {
    _showItemFormDialog(item);
  }

  void _showItemFormDialog(ComfortItemModel? existingItem) {
    final nameController =
        TextEditingController(text: existingItem?.name ?? '');
    final descController =
        TextEditingController(text: existingItem?.description ?? '');
    final locationController =
        TextEditingController(text: existingItem?.location ?? '');
    final notesController =
        TextEditingController(text: existingItem?.notes ?? '');
    String category = existingItem?.category ?? 'Objet sensoriel';
    String importance = existingItem?.importance ?? 'important';
    String availability = existingItem?.availability ?? 'disponible';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            existingItem == null ? 'Nouvel élément' : 'Modifier l\'élément'),
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
                value: category,
                decoration: InputDecoration(labelText: 'Catégorie'),
                items: [
                  'Objet sensoriel',
                  'Jouet',
                  'Vêtement',
                  'Nourriture/Boisson',
                  'Activité',
                  'Musique/Son',
                  'Autre'
                ]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => category = value!,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: importance,
                decoration: InputDecoration(labelText: 'Importance'),
                items: [
                  DropdownMenuItem(
                      value: 'essentiel', child: Text('Essentiel')),
                  DropdownMenuItem(
                      value: 'important', child: Text('Important')),
                  DropdownMenuItem(value: 'modéré', child: Text('Modéré')),
                  DropdownMenuItem(
                      value: 'optionnel', child: Text('Optionnel')),
                ],
                onChanged: (value) => importance = value!,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: availability,
                decoration: InputDecoration(labelText: 'Disponibilité'),
                items: [
                  DropdownMenuItem(
                      value: 'disponible', child: Text('Disponible')),
                  DropdownMenuItem(
                      value: 'indisponible', child: Text('Indisponible')),
                  DropdownMenuItem(
                      value: 'à remplacer', child: Text('À remplacer')),
                ],
                onChanged: (value) => availability = value!,
              ),
              SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(labelText: 'Emplacement'),
              ),
              SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
                maxLines: 2,
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
                if (existingItem == null) {
                  items.add(
                    ComfortItemModel(
                      id: items.length + 1,
                      name: nameController.text,
                      description: descController.text,
                      category: category,
                      importance: importance,
                      availability: availability,
                      location: locationController.text,
                      notes: notesController.text,
                    ),
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(existingItem == null
                      ? 'Élément ajouté'
                      : 'Élément modifié'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
            child: Text(existingItem == null ? 'Ajouter' : 'Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(ComfortItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'élément'),
        content: Text('Voulez-vous vraiment supprimer "${item.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                items.remove(item);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Élément supprimé'),
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
