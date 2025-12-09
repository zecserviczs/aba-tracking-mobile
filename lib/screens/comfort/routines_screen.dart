import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/comfort_models.dart';
import '../../models/child_model.dart';
import '../../services/comfort_service.dart';

class RoutinesScreen extends StatefulWidget {
  final Child child;

  const RoutinesScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen>
    with TickerProviderStateMixin {
  List<Routine> _routines = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRoutines();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutines() async {
    try {
      setState(() => _isLoading = true);
      final routines = await ComfortService.getChildRoutines(widget.child.id!);
      setState(() {
        _routines = routines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des routines: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/children/${widget.child.id}/comfort'),
        ),
        title: Text('Routines - ${widget.child.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Toutes les routines', icon: Icon(Icons.list)),
            Tab(text: 'Par type', icon: Icon(Icons.category)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoutines,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllRoutinesTab(),
                _buildByTypeTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/children/${widget.child.id}/comfort/routines/new'),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAllRoutinesTab() {
    if (_routines.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune routine configurée',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des routines pour aider votre enfant',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Grouper les routines par statut
    final activeRoutines = _routines.where((r) => r.isActive).toList();
    final inactiveRoutines = _routines.where((r) => !r.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadRoutines,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeRoutines.isNotEmpty) ...[
            const Text(
              'Routines actives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...activeRoutines.map((routine) => _buildRoutineCard(routine)),
            const SizedBox(height: 24),
          ],
          if (inactiveRoutines.isNotEmpty) ...[
            const Text(
              'Routines inactives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...inactiveRoutines.map((routine) => _buildRoutineCard(routine)),
          ],
        ],
      ),
    );
  }

  Widget _buildByTypeTab() {
    final groupedRoutines = <RoutineType, List<Routine>>{};

    for (final routine in _routines) {
      groupedRoutines.putIfAbsent(routine.type, () => []).add(routine);
    }

    if (groupedRoutines.isEmpty) {
      return const Center(
        child: Text(
          'Aucune routine configurée',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRoutines,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedRoutines.length,
        itemBuilder: (context, index) {
          final type = groupedRoutines.keys.elementAt(index);
          final routines = groupedRoutines[type]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Icon(
                _getRoutineIcon(type),
                color: _getRoutineColor(type),
              ),
              title: Text(type.displayName),
              subtitle: Text('${routines.length} routine(s)'),
              children: routines
                  .map((routine) => _buildRoutineTile(routine))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoutineCard(Routine routine) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoutineColor(routine.type),
          child: Icon(
            _getRoutineIcon(routine.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(routine.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(routine.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  routine.scheduledTime,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Priorité ${routine.priority}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                routine.isActive ? Icons.pause : Icons.play_arrow,
                color: routine.isActive ? Colors.orange : Colors.green,
              ),
              onPressed: () => _toggleRoutine(routine),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => context.push(
                  '/children/${widget.child.id}/comfort/routines/${routine.id}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRoutine(routine),
            ),
          ],
        ),
        onTap: () => context.push(
            '/children/${widget.child.id}/comfort/routines/${routine.id}'),
      ),
    );
  }

  Widget _buildRoutineTile(Routine routine) {
    return ListTile(
      leading: Icon(
        routine.isActive ? Icons.check_circle : Icons.cancel,
        color: routine.isActive ? Colors.green : Colors.red,
      ),
      title: Text(routine.name),
      subtitle: Text('${routine.scheduledTime} - Priorité ${routine.priority}'),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => context.push(
            '/children/${widget.child.id}/comfort/routines/${routine.id}/edit'),
      ),
      onTap: () => context
          .push('/children/${widget.child.id}/comfort/routines/${routine.id}'),
    );
  }

  Future<void> _toggleRoutine(Routine routine) async {
    try {
      await ComfortService.toggleRoutine(routine.id!);
      _loadRoutines();
      _showSuccessSnackBar(
          routine.isActive ? 'Routine désactivée' : 'Routine activée');
    } catch (e) {
      _showErrorSnackBar('Erreur lors du changement d\'état: $e');
    }
  }

  Future<void> _deleteRoutine(Routine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la routine'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer la routine "${routine.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ComfortService.deleteRoutine(routine.id!);
        _loadRoutines();
        _showSuccessSnackBar('Routine supprimée');
      } catch (e) {
        _showErrorSnackBar('Erreur lors de la suppression: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
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
}

