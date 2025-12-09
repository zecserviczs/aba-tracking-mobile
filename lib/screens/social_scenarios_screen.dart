import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/child_model.dart';
import '../models/social_scenario_models.dart';
import '../services/api_service.dart';
import '../widgets/app_drawer.dart';

class SocialScenariosScreen extends ConsumerStatefulWidget {
  const SocialScenariosScreen({super.key});

  @override
  ConsumerState<SocialScenariosScreen> createState() =>
      _SocialScenariosScreenState();
}

class _SocialScenariosScreenState extends ConsumerState<SocialScenariosScreen> {
  String? _userType;
  bool _initializing = true;
  bool _loading = false;
  String? _error;

  // Professional data
  List<SocialScenarioModel> _myScenarios = [];
  List<SocialScenarioModel> _pendingScenarios = [];
  List<SocialScenarioModel> _validatedScenarios = [];
  List<Child> _authorizedChildren = [];
  List<ScenarioGenerationContext> _contexts = [];
  bool _loadingContexts = false;

  // Parent data
  List<SocialScenarioModel> _parentScenarios = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  bool get _isProfessional => _userType == 'professional';

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    setState(() {
      _userType = prefs.getString('userType');
      _initializing = false;
    });

    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (_isProfessional) {
        final my = await ApiService.getMyProfessionalScenarios();
        final pending = await ApiService.getPendingProfessionalScenarios();
        final validated = await ApiService.getValidatedProfessionalScenarios();
        final children =
            await ApiService.getAuthorizedChildren(userType: 'professional');

        if (!mounted) return;
        setState(() {
          _myScenarios = my;
          _pendingScenarios = pending;
          _validatedScenarios = validated;
          _authorizedChildren = children;
        });
      } else {
        final scenarios = await ApiService.getParentScenarios();
        if (!mounted) return;
        setState(() {
          _parentScenarios = scenarios;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _ensureContextsLoaded() async {
    if (_contexts.isNotEmpty || _loadingContexts) return;

    setState(() {
      _loadingContexts = true;
    });

    try {
      final contexts = await ApiService.getScenarioGenerationContexts();
      if (!mounted) return;
      setState(() {
        _contexts = contexts;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des contextes : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingContexts = false;
        });
      }
    }
  }

  Future<void> _openAutoGenerationSheet() async {
    if (!_isProfessional) return;

    if (_authorizedChildren.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun enfant autorisé pour générer des scénarios.'),
        ),
      );
      return;
    }

    await _ensureContextsLoaded();
    if (_contexts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de récupérer les contextes disponibles.'),
        ),
      );
      return;
    }

    final children = List<Child>.from(_authorizedChildren);
    final contexts = List<ScenarioGenerationContext>.from(_contexts);

    int selectedChildId = children.first.id;
    String selectedContextCode = contexts.first.code;
    int scenarioCount = 5;
    bool submitting = false;
    String? localError;

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Génération automatique',
                      style: Theme.of(ctx).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Enfant concerné',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedChildId,
                      items: children
                          .map(
                            (child) => DropdownMenuItem<int>(
                              value: child.id,
                              child: Text('${child.name} (${child.age} ans)'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          selectedChildId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Contexte de vie courante',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedContextCode,
                      items: contexts
                          .map(
                            (contextItem) => DropdownMenuItem<String>(
                              value: contextItem.code,
                              child: Text(contextItem.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setSheetState(() {
                          selectedContextCode = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Nombre de scénarios :'),
                        const SizedBox(width: 16),
                        DropdownButton<int>(
                          value: scenarioCount,
                          items: List<int>.generate(10, (i) => i + 1)
                              .map(
                                (value) => DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setSheetState(() {
                              scenarioCount = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        localError!,
                        style: TextStyle(
                          color: Theme.of(ctx).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          submitting
                              ? 'Génération en cours...'
                              : 'Générer les scénarios',
                        ),
                        onPressed: submitting
                            ? null
                            : () async {
                                setSheetState(() {
                                  submitting = true;
                                  localError = null;
                                });
                                try {
                                  final generated =
                                      await ApiService.autoGenerateScenarios(
                                    childId: selectedChildId,
                                    contextCode: selectedContextCode,
                                    count: scenarioCount,
                                  );
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  await _loadData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${generated.length} scénario(s) généré(s) avec succès.',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  setSheetState(() {
                                    submitting = false;
                                    localError = e.toString();
                                  });
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scénarios Sociaux',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (_isProfessional) ...[
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Génération automatique',
              onPressed: _loading ? null : _openAutoGenerationSheet,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Créer un scénario',
              onPressed: _showAddScenarioDialog,
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Créer un scénario',
              onPressed: () => context.go('/create-social-scenario'),
            ),
          ],
        ],
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _loading &&
                  (_isProfessional
                      ? _myScenarios.isEmpty &&
                          _pendingScenarios.isEmpty &&
                          _validatedScenarios.isEmpty
                      : _parentScenarios.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  children: _buildContent(),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isProfessional
            ? _showAddScenarioDialog
            : () => context.go('/create-social-scenario'),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Widget> _buildContent() {
    if (_error != null) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ];
    }

    if (_isProfessional) {
      return [
        _buildProfessionalHeader(),
        const SizedBox(height: 16),
        _buildScenarioSection('Mes scénarios', _myScenarios),
        _buildScenarioSection('En attente de validation', _pendingScenarios),
        _buildScenarioSection('Validés par les parents', _validatedScenarios),
      ];
    } else {
      return [
        _buildParentHeader(),
        const SizedBox(height: 16),
        _buildScenarioSection('Mes scénarios', _parentScenarios),
      ];
    }
  }

  Widget _buildProfessionalHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestion professionnelle',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Générez automatiquement des scénarios en fonction des besoins des enfants autorisés, validez ou consultez vos scénarios existants.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Génération automatique'),
                  onPressed: _loading ? null : _openAutoGenerationSheet,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  onPressed: _loading ? null : _loadData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scénarios familiaux',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Créez vos propres scénarios sociaux et validez ceux proposés par les professionnels.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Créer un scénario'),
                  onPressed: _loading ? null : () => context.go('/create-social-scenario'),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser'),
                  onPressed: _loading ? null : _loadData,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioSection(String title, List<SocialScenarioModel> scenarios) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (scenarios.isEmpty)
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun scénario disponible.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...scenarios.map(_buildScenarioCard),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildScenarioCard(SocialScenarioModel scenario) {
    final badges = <Widget>[];
    if (scenario.childName != null && scenario.childName!.isNotEmpty) {
      badges.add(_buildBadge(scenario.childName!, Colors.blue.shade100, Colors.blue.shade900));
    }
    if (scenario.validatedByParent) {
      badges.add(_buildBadge('Validé parent', Colors.green.shade100, Colors.green.shade900));
    } else {
      badges.add(_buildBadge('En attente', Colors.orange.shade100, Colors.orange.shade900));
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    scenario.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () => _showScenarioDetails(scenario),
                  tooltip: 'Voir les détails',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scenario.description?.isNotEmpty == true
                  ? scenario.description!
                  : 'Aucune description fournie.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges,
            ),
            if (scenario.steps.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Étapes principales :',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...scenario.steps.take(3).map(
                    (step) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (step.icon != null)
                          Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _getColorFromHex(step.color ?? '#2196f3'),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconData(step.icon!),
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        else
                          Text(
                            '• ',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            step.text ?? step.description ?? 'Étape sans description',
                          ),
                        ),
                      ],
                    ),
                  ),
              if (scenario.steps.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '... (${scenario.steps.length - 3} étape(s) supplémentaire(s))',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColorFromHex(String hex) {
    try {
      return Color(int.parse(hex.replaceAll('#', '0xFF')));
    } catch (e) {
      return Color(0xFF2196f3); // Couleur par défaut
    }
  }

  IconData _getIconData(String iconName) {
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

  void _showScenarioDetails(SocialScenarioModel scenario) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        bool validating = false;
        String? validationError;
        return StatefulBuilder(
          builder: (context, setState) {
            final canValidate =
                !_isProfessional && !(scenario.validatedByParent);
            return AlertDialog(
              title: Text(scenario.title),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (scenario.childName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Enfant : ${scenario.childName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    Text(
                      scenario.description?.isNotEmpty == true
                          ? scenario.description!
                          : 'Aucune description fournie.',
                    ),
                    const SizedBox(height: 16),
                    if (validationError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          validationError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Text(
                      'Étapes :',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...scenario.steps.asMap().entries.map(
                          (entry) {
                            final step = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: step.icon != null
                                  ? Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getColorFromHex(step.color ?? '#2196f3'),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getIconData(step.icon!),
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                              title: Text(
                                step.text ?? step.description ?? '',
                              ),
                            );
                          },
                        ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Fermer'),
                ),
                if (canValidate)
                  ElevatedButton.icon(
                    icon: validating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      validating ? 'Validation...' : 'Valider',
                    ),
                    onPressed: validating
                        ? null
                        : () async {
                            setState(() {
                              validating = true;
                              validationError = null;
                            });
                            try {
                              await ApiService.validateScenario(scenario.id);
                              if (!mounted) return;
                              Navigator.pop(ctx);
                              await _loadData();
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                  content: Text('Scénario validé.'),
                                ),
                              );
                            } catch (e) {
                              setState(() {
                                validating = false;
                                validationError = e.toString();
                              });
                            }
                          },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddScenarioDialog() {
    context.go('/create-social-scenario');
  }
}

