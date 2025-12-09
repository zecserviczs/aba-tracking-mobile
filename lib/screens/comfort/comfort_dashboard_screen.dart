import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/comfort_models.dart';
import '../../models/child_model.dart';
import '../../services/comfort_service.dart';

class ComfortDashboardScreen extends StatefulWidget {
  final Child child;

  const ComfortDashboardScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ComfortDashboardScreen> createState() => _ComfortDashboardScreenState();
}

class _ComfortDashboardScreenState extends State<ComfortDashboardScreen> {
  ComfortStats? _stats;
  List<Routine> _recentRoutines = [];
  List<ComfortItem> _criticalItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final stats = await ComfortService.getComfortStats(widget.child.id!);
      final routines =
          await ComfortService.getActiveChildRoutines(widget.child.id!);
      final criticalItems =
          await ComfortService.getCriticalComfortItems(widget.child.id!);

      setState(() {
        _stats = stats;
        _recentRoutines = routines.take(3).toList();
        _criticalItems = criticalItems.take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des données: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/parent-dashboard');
          },
        ),
        title: Text('Confort - ${widget.child.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suivi des routines et objets de confort de votre enfant. '
                      'Utilisez les actions rapides pour ajouter une routine ou un élément, '
                      'consulter les routines du matin/soir ou vérifier le stock.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentRoutines(),
                    const SizedBox(height: 24),
                    _buildCriticalItems(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vue d\'ensemble',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Routines actives',
                _stats!.totalRoutines.toString(),
                Icons.schedule,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Éléments de confort',
                _stats!.totalComfortItems.toString(),
                Icons.favorite,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Éléments critiques',
                _stats!.criticalItems.toString(),
                Icons.priority_high,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'À remplacer',
                _stats!.itemsNeedingReplacement.toString(),
                Icons.warning,
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Nouvelle routine',
                Icons.schedule,
                Colors.blue,
                () => context
                    .push('/children/${widget.child.id}/comfort/routines/new'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Nouvel élément',
                Icons.favorite,
                Colors.red,
                () => context
                    .push('/children/${widget.child.id}/comfort/items/new'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Routines du matin',
                Icons.wb_sunny,
                Colors.orange,
                () => context.push(
                    '/children/${widget.child.id}/comfort/routines/morning'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Routines du soir',
                Icons.nights_stay,
                Colors.indigo,
                () => context.push(
                    '/children/${widget.child.id}/comfort/routines/evening'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Vérifications de stock',
                Icons.inventory,
                Colors.teal,
                () => context.push('/children/${widget.child.id}/stock'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Statistiques',
                Icons.analytics,
                Colors.purple,
                () => _showStatsDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentRoutines() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Routines récentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context
                  .push('/children/${widget.child.id}/comfort/routines'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_recentRoutines.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Aucune routine configurée'),
              ),
            ),
          )
        else
          ..._recentRoutines.map((routine) => _buildRoutineCard(routine)),
      ],
    );
  }

  Widget _buildRoutineCard(Routine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getRoutineIcon(routine.type),
          color: _getRoutineColor(routine.type),
        ),
        title: Text(routine.name),
        subtitle:
            Text('${routine.scheduledTime} - ${routine.type.displayName}'),
        trailing: routine.isActive
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.cancel, color: Colors.red),
        onTap: () => context.push(
            '/children/${widget.child.id}/comfort/routines/${routine.id}'),
      ),
    );
  }

  Widget _buildCriticalItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Éléments critiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context
                  .push('/children/${widget.child.id}/comfort/items'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_criticalItems.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text('Aucun élément critique configuré'),
              ),
            ),
          )
        else
          ..._criticalItems.map((item) => _buildComfortItemCard(item)),
      ],
    );
  }

  Widget _buildComfortItemCard(ComfortItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getComfortItemIcon(item.type),
          color: item.comfortLevel.color,
        ),
        title: Text(item.name),
        subtitle:
            Text('${item.type.displayName} - ${item.comfortLevel.displayName}'),
        trailing: item.needsReplacement
            ? const Icon(Icons.warning, color: Colors.orange)
            : item.isAvailable
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.cancel, color: Colors.red),
        onTap: () => context
            .push('/children/${widget.child.id}/comfort/items/${item.id}'),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Nouvelle routine'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                      '/children/${widget.child.id}/comfort/routines/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Nouvel élément de confort'),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .push('/children/${widget.child.id}/comfort/items/new');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Statistiques de confort'),
        content: _stats != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Routines actives: ${_stats!.totalRoutines}'),
                  Text('Éléments de confort: ${_stats!.totalComfortItems}'),
                  Text('Éléments critiques: ${_stats!.criticalItems}'),
                  Text('À remplacer: ${_stats!.itemsNeedingReplacement}'),
                ],
              )
            : const Text('Aucune donnée disponible'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  IconData _getRoutineIcon(RoutineType type) {
    switch (type) {
      case RoutineType.MORNING:
        return Icons.wb_sunny;
      case RoutineType.EVENING:
        return Icons.nights_stay;
      case RoutineType.BEDTIME:
        return Icons.bedtime;
      case RoutineType.MEAL:
        return Icons.restaurant;
      case RoutineType.ACTIVITY:
        return Icons.sports_esports;
      case RoutineType.TRANSITION:
        return Icons.swap_horiz;
      case RoutineType.HYGIENE:
        return Icons.face;
      case RoutineType.LEARNING:
        return Icons.school;
    }
  }

  Color _getRoutineColor(RoutineType type) {
    switch (type) {
      case RoutineType.MORNING:
        return Colors.orange;
      case RoutineType.EVENING:
        return Colors.indigo;
      case RoutineType.BEDTIME:
        return Colors.purple;
      case RoutineType.MEAL:
        return Colors.green;
      case RoutineType.ACTIVITY:
        return Colors.blue;
      case RoutineType.TRANSITION:
        return Colors.teal;
      case RoutineType.HYGIENE:
        return Colors.cyan;
      case RoutineType.LEARNING:
        return Colors.amber;
    }
  }

  IconData _getComfortItemIcon(ComfortItemType type) {
    switch (type) {
      case ComfortItemType.FOOD:
        return Icons.restaurant;
      case ComfortItemType.BEVERAGE:
        return Icons.local_drink;
      case ComfortItemType.BATH_PRODUCT:
        return Icons.shower;
      case ComfortItemType.PERFUME:
        return Icons.spa;
      case ComfortItemType.CLOTHING:
        return Icons.checkroom;
      case ComfortItemType.TOY:
        return Icons.toys;
      case ComfortItemType.BOOK:
        return Icons.menu_book;
      case ComfortItemType.BLANKET:
      case ComfortItemType.PILLOW:
        return Icons.bed;
      case ComfortItemType.FURNITURE:
        return Icons.chair;
      case ComfortItemType.DECORATION:
        return Icons.palette;
      case ComfortItemType.LIGHTING:
        return Icons.lightbulb;
      case ComfortItemType.SOUND:
        return Icons.volume_up;
      case ComfortItemType.TEXTURE:
        return Icons.touch_app;
      case ComfortItemType.SMELL:
        return Icons.air;
      case ComfortItemType.ROUTINE_OBJECT:
        return Icons.schedule;
      case ComfortItemType.TRANSITION_OBJECT:
        return Icons.swap_horiz;
      case ComfortItemType.SENSORY_TOOL:
        return Icons.psychology;
      case ComfortItemType.OTHER:
        return Icons.category;
    }
  }
}
