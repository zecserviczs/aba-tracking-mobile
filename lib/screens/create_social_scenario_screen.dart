import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_drawer.dart';
import '../models/child_model.dart';
import '../services/api_service.dart';

class ScenarioStepData {
  String text;
  String? icon;
  String? color;

  ScenarioStepData({
    this.text = '',
    this.icon,
    this.color,
  });
}

class IconOption {
  final String icon;
  final String label;
  final String description;

  const IconOption({
    required this.icon,
    required this.label,
    required this.description,
  });
}

class CreateSocialScenarioScreen extends ConsumerStatefulWidget {
  const CreateSocialScenarioScreen({super.key});

  @override
  ConsumerState<CreateSocialScenarioScreen> createState() => _CreateSocialScenarioScreenState();
}

class _CreateSocialScenarioScreenState extends ConsumerState<CreateSocialScenarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<ScenarioStepData> _steps = [ScenarioStepData()];
  List<Child> _children = [];
  int? _selectedChildId;
  String? _userType;
  bool _isLoading = false;
  bool _isLoadingChildren = false;
  String? _error;
  int? _selectedStepForIconPicker;

  static const List<IconOption> _availableIcons = [
    // Actions quotidiennes
    IconOption(icon: 'child_care', label: 'Enfant', description: 'Enfant'),
    IconOption(icon: 'directions_walk', label: 'Marcher', description: 'Enfant qui marche'),
    IconOption(icon: 'directions_run', label: 'Courir', description: 'Enfant qui court'),
    IconOption(icon: 'sports_soccer', label: 'Jouer au foot', description: 'Enfant qui joue au football'),
    IconOption(icon: 'sports_basketball', label: 'Jouer au basket', description: 'Enfant qui joue au basket'),
    IconOption(icon: 'pool', label: 'Nager', description: 'Enfant qui nage'),
    IconOption(icon: 'directions_bike', label: 'Vélo', description: 'Enfant à vélo'),
    
    // École et apprentissage
    IconOption(icon: 'school', label: 'École', description: 'Enfant à l\'école'),
    IconOption(icon: 'menu_book', label: 'Lire', description: 'Enfant qui lit'),
    IconOption(icon: 'edit', label: 'Écrire', description: 'Enfant qui écrit'),
    IconOption(icon: 'calculate', label: 'Calculer', description: 'Enfant qui calcule'),
    IconOption(icon: 'palette', label: 'Dessiner', description: 'Enfant qui dessine'),
    IconOption(icon: 'music_note', label: 'Musique', description: 'Enfant qui fait de la musique'),
    
    // Repas
    IconOption(icon: 'restaurant', label: 'Manger', description: 'Enfant qui mange'),
    IconOption(icon: 'lunch_dining', label: 'Déjeuner', description: 'Enfant qui déjeune'),
    IconOption(icon: 'breakfast_dining', label: 'Petit-déj', description: 'Enfant qui prend son petit-déjeuner'),
    IconOption(icon: 'dinner_dining', label: 'Dîner', description: 'Enfant qui dîne'),
    IconOption(icon: 'local_cafe', label: 'Boire', description: 'Enfant qui boit'),
    
    // Hygiène et soins
    IconOption(icon: 'shower', label: 'Douche', description: 'Enfant qui prend une douche'),
    IconOption(icon: 'bathtub', label: 'Bain', description: 'Enfant qui prend un bain'),
    IconOption(icon: 'soap', label: 'Se laver', description: 'Enfant qui se lave'),
    IconOption(icon: 'wc', label: 'Toilettes', description: 'Enfant aux toilettes'),
    IconOption(icon: 'checkroom', label: 'S\'habiller', description: 'Enfant qui s\'habille'),
    
    // Activités créatives
    IconOption(icon: 'toys', label: 'Jouer', description: 'Enfant qui joue'),
    IconOption(icon: 'sports_esports', label: 'Jeux vidéo', description: 'Enfant qui joue aux jeux vidéo'),
    IconOption(icon: 'brush', label: 'Peindre', description: 'Enfant qui peint'),
    IconOption(icon: 'camera_alt', label: 'Photo', description: 'Enfant qui prend une photo'),
    IconOption(icon: 'auto_stories', label: 'Histoire', description: 'Enfant qui écoute une histoire'),
    
    // Social et émotions
    IconOption(icon: 'people', label: 'Avec amis', description: 'Enfant avec des amis'),
    IconOption(icon: 'group', label: 'Groupe', description: 'Enfant dans un groupe'),
    IconOption(icon: 'handshake', label: 'Saluer', description: 'Enfant qui salue'),
    IconOption(icon: 'sentiment_satisfied', label: 'Content', description: 'Enfant content'),
    IconOption(icon: 'emoji_emotions', label: 'Joyeux', description: 'Enfant joyeux'),
    IconOption(icon: 'thumb_up', label: 'Bravo', description: 'Enfant qui fait bravo'),
    IconOption(icon: 'celebration', label: 'Fêter', description: 'Enfant qui fête'),
    
    // Repos et sommeil
    IconOption(icon: 'bedtime', label: 'Dormir', description: 'Enfant qui dort'),
    IconOption(icon: 'hotel', label: 'Lit', description: 'Enfant au lit'),
    IconOption(icon: 'airline_seat_flat', label: 'Repos', description: 'Enfant qui se repose'),
    
    // Transports
    IconOption(icon: 'directions_car', label: 'Voiture', description: 'Enfant en voiture'),
    IconOption(icon: 'train', label: 'Train', description: 'Enfant dans le train'),
    IconOption(icon: 'flight', label: 'Avion', description: 'Enfant dans l\'avion'),
    IconOption(icon: 'directions_bus', label: 'Bus', description: 'Enfant dans le bus'),
    
    // Activités extérieures
    IconOption(icon: 'park', label: 'Parc', description: 'Enfant au parc'),
    IconOption(icon: 'beach_access', label: 'Plage', description: 'Enfant à la plage'),
    IconOption(icon: 'nature_people', label: 'Nature', description: 'Enfant dans la nature'),
    
    // Maison
    IconOption(icon: 'home', label: 'Maison', description: 'Enfant à la maison'),
    IconOption(icon: 'tv', label: 'Télévision', description: 'Enfant qui regarde la TV'),
    IconOption(icon: 'computer', label: 'Ordinateur', description: 'Enfant sur l\'ordinateur'),
    IconOption(icon: 'phone', label: 'Téléphone', description: 'Enfant au téléphone'),
    
    // Soins médicaux
    IconOption(icon: 'local_hospital', label: 'Hôpital', description: 'Enfant à l\'hôpital'),
    IconOption(icon: 'local_pharmacy', label: 'Pharmacie', description: 'Enfant à la pharmacie'),
    IconOption(icon: 'medical_services', label: 'Médecin', description: 'Enfant chez le médecin'),
    
    // Autres
    IconOption(icon: 'shopping_cart', label: 'Courses', description: 'Enfant qui fait les courses'),
    IconOption(icon: 'store', label: 'Magasin', description: 'Enfant au magasin'),
    IconOption(icon: 'fitness_center', label: 'Sport', description: 'Enfant qui fait du sport'),
    IconOption(icon: 'pets', label: 'Animaux', description: 'Enfant avec des animaux'),
    IconOption(icon: 'help_outline', label: 'Aide', description: 'Enfant qui demande de l\'aide'),
    IconOption(icon: 'info', label: 'Information', description: 'Enfant qui apprend'),
    IconOption(icon: 'check_circle', label: 'Terminé', description: 'Enfant qui a terminé'),
    IconOption(icon: 'cancel', label: 'Annuler', description: 'Enfant qui annule'),
    IconOption(icon: 'add', label: 'Ajouter', description: 'Enfant qui ajoute'),
    IconOption(icon: 'remove', label: 'Retirer', description: 'Enfant qui retire'),
  ];

  static const List<Map<String, String>> _availableColors = [
    {'name': 'Bleu vif', 'value': '#2196f3'},
    {'name': 'Vert pomme', 'value': '#4caf50'},
    {'name': 'Rouge cerise', 'value': '#f44336'},
    {'name': 'Orange soleil', 'value': '#ff9800'},
    {'name': 'Violet', 'value': '#9c27b0'},
    {'name': 'Rose bonbon', 'value': '#e91e63'},
    {'name': 'Jaune soleil', 'value': '#ffeb3b'},
    {'name': 'Cyan ciel', 'value': '#00bcd4'},
    {'name': 'Vert menthe', 'value': '#26a69a'},
    {'name': 'Rouge framboise', 'value': '#e53935'},
    {'name': 'Bleu océan', 'value': '#1976d2'},
    {'name': 'Vert forêt', 'value': '#2e7d32'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserTypeAndChildren();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTypeAndChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    setState(() {
      _userType = userType;
    });

    await _loadChildren();
  }

  Future<void> _loadChildren() async {
    setState(() {
      _isLoadingChildren = true;
      _error = null;
    });

    try {
      final children = await ApiService.getAuthorizedChildren(userType: _userType);
      setState(() {
        _children = children;
        if (children.isNotEmpty) {
          _selectedChildId = children.first.id;
        }
        _isLoadingChildren = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des enfants: $e';
        _isLoadingChildren = false;
      });
    }
  }

  void _addStep() {
    setState(() {
      _steps.add(ScenarioStepData());
    });
  }

  void _removeStep(int index) {
    if (_steps.length > 1) {
      setState(() {
        _steps.removeAt(index);
      });
    }
  }

  void _updateStep(int index, String value) {
    setState(() {
      _steps[index] = ScenarioStepData(
        text: value,
        icon: _steps[index].icon,
        color: _steps[index].color,
      );
    });
  }

  void _toggleIconPicker(int index) {
    setState(() {
      if (_selectedStepForIconPicker == index) {
        _selectedStepForIconPicker = null;
      } else {
        _selectedStepForIconPicker = index;
      }
    });
  }

  void _selectIcon(int stepIndex, String icon) {
    setState(() {
      _steps[stepIndex] = ScenarioStepData(
        text: _steps[stepIndex].text,
        icon: icon,
        color: _steps[stepIndex].color ?? '#2196f3',
      );
      _selectedStepForIconPicker = null;
    });
  }

  void _selectColor(int stepIndex, String color) {
    setState(() {
      _steps[stepIndex] = ScenarioStepData(
        text: _steps[stepIndex].text,
        icon: _steps[stepIndex].icon,
        color: color,
      );
    });
  }

  void _clearIcon(int stepIndex) {
    setState(() {
      _steps[stepIndex] = ScenarioStepData(
        text: _steps[stepIndex].text,
        icon: null,
        color: null,
      );
    });
  }

  Future<void> _saveScenario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un enfant'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Vérifier qu'au moins un step n'est pas vide
    final nonEmptySteps = _steps.where((step) => step.text.trim().isNotEmpty).toList();
    if (nonEmptySteps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins une étape'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Préparer les étapes au format attendu par l'API
      final stepsWithText = nonEmptySteps.map((step) {
        final stepData = <String, dynamic>{
          'text': step.text.trim(),
        };
        if (step.icon != null) {
          stepData['icon'] = step.icon;
        }
        if (step.color != null) {
          stepData['color'] = step.color;
        }
        return stepData;
      }).toList();

      // Préparer le DTO
      final dto = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'childId': _selectedChildId,
        'shared': false, // Par défaut, le scénario n'est pas partagé
        'steps': stepsWithText,
      };

      // Appeler l'API pour créer le scénario
      final response = await ApiService.post('/social-scenarios', dto);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Scénario créé avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          
          context.go('/social-scenarios');
        }
      } else {
        throw Exception('Erreur lors de la création du scénario');
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de la création: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Créer un Scénario Social',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/social-scenarios'),
        ),
        actions: [
          if (_isLoading)
            Padding(
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
        ],
      ),
      drawer: const AppDrawer(),
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
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations générales
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations générales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Titre du scénario',
                            hintText: 'Ex: Demander de l\'aide',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez saisir un titre';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Description du scénario...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Veuillez saisir une description';
                            }
                            return null;
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        if (_isLoadingChildren)
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Chargement des enfants...'),
                              ],
                            ),
                          )
                        else if (_error != null)
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          DropdownButtonFormField<int>(
                            value: _selectedChildId,
                            decoration: InputDecoration(
                              labelText: 'Enfant *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: Icon(Icons.child_care),
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
                            validator: (value) {
                              if (value == null) {
                                return 'Veuillez sélectionner un enfant';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Étapes du scénario
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Étapes du scénario',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _addStep,
                              icon: Icon(Icons.add_circle),
                              color: Colors.green[700],
                              tooltip: 'Ajouter une étape',
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        
                        ...List.generate(_steps.length, (index) {
                          return _buildStepCard(index);
                        }),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => context.go('/social-scenarios'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveScenario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Créer le scénario'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int index) {
    final step = _steps[index];
    final showPicker = _selectedStepForIconPicker == index;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                        '${index + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: step.text,
                      decoration: InputDecoration(
                        hintText: 'Étape ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onChanged: (value) => _updateStep(index, value),
                    ),
                  ),
                  if (_steps.length > 1)
                    IconButton(
                      onPressed: () => _removeStep(index),
                      icon: Icon(Icons.remove_circle),
                      color: Colors.red,
                      tooltip: 'Supprimer cette étape',
                    ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Pictogramme
              Text(
                '🎨 Pictogramme (optionnel)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              
              // Aperçu du pictogramme
              if (step.icon != null)
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _hexToColor(step.color ?? '#2196f3'),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIconData(step.icon!),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _clearIcon(index),
                        icon: Icon(Icons.delete, size: 18),
                        label: Text('Effacer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              
              SizedBox(height: 8),
              
              ElevatedButton.icon(
                onPressed: () => _toggleIconPicker(index),
                icon: Icon(step.icon != null ? Icons.edit : Icons.add_circle),
                label: Text(step.icon != null ? 'Changer le pictogramme' : 'Choisir un pictogramme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                ),
              ),
              
              // Sélecteur d'icônes et couleurs
              if (showPicker) ...[
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choisis un pictogramme',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        height: 300,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _availableIcons.length,
                          itemBuilder: (context, iconIndex) {
                            final iconOption = _availableIcons[iconIndex];
                            final isSelected = step.icon == iconOption.icon;
                            return InkWell(
                              onTap: () => _selectIcon(index, iconOption.icon),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _hexToColor(step.color ?? '#2196f3')
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? _hexToColor(step.color ?? '#2196f3')
                                        : Colors.grey.shade400,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getIconData(iconOption.icon),
                                      size: 32,
                                      color: isSelected ? Colors.white : Colors.grey.shade700,
                                    ),
                                    SizedBox(height: 4),
                                    Flexible(
                                      child: Text(
                                        iconOption.label,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isSelected ? Colors.white : Colors.grey.shade700,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      if (step.icon != null) ...[
                        SizedBox(height: 16),
                        Text(
                          'Choisis une couleur',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _availableColors.map((colorData) {
                            final colorValue = colorData['value']!;
                            final isSelected = step.color == colorValue;
                            return InkWell(
                              onTap: () => _selectColor(index, colorValue),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _hexToColor(colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.black : Colors.white,
                                    width: isSelected ? 4 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: isSelected
                                    ? Icon(Icons.check_circle, color: Colors.white, size: 28)
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton(
                          onPressed: () => _toggleIconPicker(index),
                          child: Text('Fermer'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    // Mapping des noms d'icônes Material Icons
    final iconMap = <String, IconData>{
      'child_care': Icons.child_care,
      'directions_walk': Icons.directions_walk,
      'directions_run': Icons.directions_run,
      'sports_soccer': Icons.sports_soccer,
      'sports_basketball': Icons.sports_basketball,
      'pool': Icons.pool,
      'directions_bike': Icons.directions_bike,
      'school': Icons.school,
      'menu_book': Icons.menu_book,
      'edit': Icons.edit,
      'calculate': Icons.calculate,
      'palette': Icons.palette,
      'music_note': Icons.music_note,
      'restaurant': Icons.restaurant,
      'lunch_dining': Icons.lunch_dining,
      'breakfast_dining': Icons.breakfast_dining,
      'dinner_dining': Icons.dinner_dining,
      'local_cafe': Icons.local_cafe,
      'shower': Icons.shower,
      'bathtub': Icons.bathtub,
      'soap': Icons.soap,
      'wc': Icons.wc,
      'checkroom': Icons.checkroom,
      'toys': Icons.toys,
      'sports_esports': Icons.sports_esports,
      'brush': Icons.brush,
      'camera_alt': Icons.camera_alt,
      'auto_stories': Icons.auto_stories,
      'people': Icons.people,
      'group': Icons.group,
      'handshake': Icons.handshake,
      'sentiment_satisfied': Icons.sentiment_satisfied,
      'emoji_emotions': Icons.emoji_emotions,
      'thumb_up': Icons.thumb_up,
      'celebration': Icons.celebration,
      'bedtime': Icons.bedtime,
      'hotel': Icons.hotel,
      'airline_seat_flat': Icons.airline_seat_flat,
      'directions_car': Icons.directions_car,
      'train': Icons.train,
      'flight': Icons.flight,
      'directions_bus': Icons.directions_bus,
      'park': Icons.park,
      'beach_access': Icons.beach_access,
      'nature_people': Icons.nature_people,
      'home': Icons.home,
      'tv': Icons.tv,
      'computer': Icons.computer,
      'phone': Icons.phone,
      'local_hospital': Icons.local_hospital,
      'local_pharmacy': Icons.local_pharmacy,
      'medical_services': Icons.medical_services,
      'shopping_cart': Icons.shopping_cart,
      'store': Icons.store,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'help_outline': Icons.help_outline,
      'info': Icons.info,
      'check_circle': Icons.check_circle,
      'cancel': Icons.cancel,
      'add': Icons.add,
      'remove': Icons.remove,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }
}
