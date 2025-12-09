import 'package:flutter/material.dart';

class ScenarioStep {
  String description;
  String? imageUrl;

  ScenarioStep({
    required this.description,
    this.imageUrl,
  });
}

class ScenarioCreationScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ScenarioCreationScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ScenarioCreationScreen> createState() => _ScenarioCreationScreenState();
}

class _ScenarioCreationScreenState extends State<ScenarioCreationScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  List<ScenarioStep> steps = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Ajouter une première étape par défaut
    _addStep();
  }

  void _addStep() {
    setState(() {
      steps.add(ScenarioStep(description: ''));
    });
  }

  void _removeStep(int index) {
    if (steps.length > 1) {
      setState(() {
        steps.removeAt(index);
      });
    }
  }

  Future<void> _pickImage(int stepIndex) async {
    // Pour l'instant, utiliser une URL d'image
    final controller = TextEditingController(text: steps[stepIndex].imageUrl ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une image'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'URL de l\'image',
            hintText: 'https://example.com/image.jpg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                steps[stepIndex].imageUrl = controller.text;
              });
              Navigator.pop(context);
            },
            child: Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveScenario() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le titre est obligatoire')),
      );
      return;
    }

    if (steps.any((step) => step.description.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toutes les étapes doivent avoir une description')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      // TODO: Upload images et créer le scénario via API
      await Future.delayed(Duration(seconds: 2));

      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scénario créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Créer un scénario'),
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
          if (isSaving)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveScenario,
              tooltip: 'Enregistrer',
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations de base
              Card(
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Text(
                      'Informations générales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.purple[700],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Titre du scénario *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title, color: Colors.purple[700]),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description, color: Colors.purple[700]),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.child_care, color: Colors.purple[700], size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Pour: ${widget.childName}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.purple[900],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Étapes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Étapes du scénario',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.add, size: 18),
                  label: Text('Ajouter une étape'),
                  onPressed: _addStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            ...steps.asMap().entries.map((entry) {
              return _buildStepCard(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildStepCard(int index, ScenarioStep step) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple[300]!, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.purple[700],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Étape ${index + 1}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple[900],
                    ),
                  ),
                ),
                if (steps.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeStep(index),
                    tooltip: 'Supprimer',
                  ),
              ],
            ),
            
            SizedBox(height: 12),
            
            TextField(
              decoration: InputDecoration(
                labelText: 'Description de l\'étape *',
                border: OutlineInputBorder(),
                hintText: 'Décrivez cette étape...',
              ),
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  step.description = value;
                });
              },
              controller: TextEditingController(text: step.description)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: step.description.length),
                ),
            ),
            
            SizedBox(height: 12),
            
            // Image
            if (step.imageUrl != null && step.imageUrl!.isNotEmpty) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      step.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: Center(
                            child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () {
                          setState(() {
                            step.imageUrl = null;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
            
            OutlinedButton.icon(
              icon: Icon(Icons.image),
              label: Text(step.imageUrl == null ? 'Ajouter une image' : 'Changer l\'image'),
              onPressed: () => _pickImage(index),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple[700],
                side: BorderSide(color: Colors.purple[300]!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}

