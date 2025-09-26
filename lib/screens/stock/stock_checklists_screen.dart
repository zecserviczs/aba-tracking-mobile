import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/stock_models.dart';
import '../../models/child_model.dart';
import '../../services/stock_service.dart';

class StockChecklistsScreen extends StatefulWidget {
  final Child child;

  const StockChecklistsScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<StockChecklistsScreen> createState() => _StockChecklistsScreenState();
}

class _StockChecklistsScreenState extends State<StockChecklistsScreen> with TickerProviderStateMixin {
  List<StockChecklist> _checklists = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChecklists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChecklists() async {
    try {
      setState(() => _isLoading = true);
      final checklists = await StockService.getChildStockChecklists(widget.child.id!);
      setState(() {
        _checklists = checklists;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des checklists: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checklists de stock - ${widget.child.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Toutes', icon: Icon(Icons.list)),
            Tab(text: 'Actives', icon: Icon(Icons.check_circle)),
            Tab(text: 'Par type', icon: Icon(Icons.category)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChecklists,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllChecklistsTab(),
                _buildActiveChecklistsTab(),
                _buildByTypeTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/children/${widget.child.id}/stock/checklists/new'),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAllChecklistsTab() {
    if (_checklists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune checklist de stock configurée',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Créez des checklists pour suivre le stock des éléments de confort',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Grouper par statut
    final activeChecklists = _checklists.where((c) => c.isActive).toList();
    final inactiveChecklists = _checklists.where((c) => !c.isActive).toList();

    return RefreshIndicator(
      onRefresh: _loadChecklists,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (activeChecklists.isNotEmpty) ...[
            const Text(
              'Checklists actives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...activeChecklists.map((checklist) => _buildChecklistCard(checklist)),
            const SizedBox(height: 24),
          ],
          if (inactiveChecklists.isNotEmpty) ...[
            const Text(
              'Checklists inactives',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...inactiveChecklists.map((checklist) => _buildChecklistCard(checklist)),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveChecklistsTab() {
    final activeChecklists = _checklists.where((c) => c.isActive).toList();

    if (activeChecklists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucune checklist active',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChecklists,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activeChecklists.length,
        itemBuilder: (context, index) => _buildChecklistCard(activeChecklists[index]),
      ),
    );
  }

  Widget _buildByTypeTab() {
    final groupedChecklists = <ChecklistType, List<StockChecklist>>{};
    
    for (final checklist in _checklists.where((c) => c.isActive)) {
      groupedChecklists.putIfAbsent(checklist.type, () => []).add(checklist);
    }

    if (groupedChecklists.isEmpty) {
      return const Center(
        child: Text(
          'Aucune checklist active',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadChecklists,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedChecklists.length,
        itemBuilder: (context, index) {
          final type = groupedChecklists.keys.elementAt(index);
          final checklists = groupedChecklists[type]!;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: type.color,
                child: Icon(type.icon, color: Colors.white),
              ),
              title: Text(type.displayName),
              subtitle: Text('${checklists.length} checklist(s)'),
              children: checklists.map((checklist) => _buildChecklistTile(checklist)).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChecklistCard(StockChecklist checklist) {
    final isOverdue = checklist.nextScheduled != null && 
                     checklist.nextScheduled!.isBefore(DateTime.now()) && 
                     !checklist.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue ? Colors.red : checklist.type.color,
          child: Icon(
            checklist.type.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(checklist.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(checklist.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  checklist.scheduledTime,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.repeat, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _getFrequencyDisplayName(checklist.frequency),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (checklist.nextScheduled != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Prochaine: ${_formatDateTime(checklist.nextScheduled!)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey[600], 
                      fontSize: 12,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOverdue)
              const Icon(Icons.warning, color: Colors.red, size: 20),
            if (checklist.isCompleted)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            IconButton(
              icon: Icon(
                checklist.isActive ? Icons.pause : Icons.play_arrow,
                color: checklist.isActive ? Colors.orange : Colors.green,
              ),
              onPressed: () => _toggleChecklist(checklist),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => context.push('/children/${widget.child.id}/stock/checklists/${checklist.id}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteChecklist(checklist),
            ),
          ],
        ),
        onTap: () => context.push('/children/${widget.child.id}/stock/checklists/${checklist.id}'),
      ),
    );
  }

  Widget _buildChecklistTile(StockChecklist checklist) {
    return ListTile(
      leading: Icon(
        checklist.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: checklist.isCompleted ? Colors.green : Colors.grey,
      ),
      title: Text(checklist.name),
      subtitle: Text('${checklist.scheduledTime} - ${_getFrequencyDisplayName(checklist.frequency)}'),
      trailing: IconButton(
        icon: const Icon(Icons.visibility),
        onPressed: () => context.push('/children/${widget.child.id}/stock/checklists/${checklist.id}'),
      ),
      onTap: () => context.push('/children/${widget.child.id}/stock/checklists/${checklist.id}'),
    );
  }

  Future<void> _toggleChecklist(StockChecklist checklist) async {
    try {
      await StockService.toggleStockChecklist(checklist.id!);
      _loadChecklists();
      _showSuccessSnackBar(
        checklist.isActive 
            ? 'Checklist désactivée' 
            : 'Checklist activée'
      );
    } catch (e) {
      _showErrorSnackBar('Erreur lors du changement d\'état: $e');
    }
  }

  Future<void> _deleteChecklist(StockChecklist checklist) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la checklist'),
        content: Text('Êtes-vous sûr de vouloir supprimer la checklist "${checklist.name}" ?'),
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
        await StockService.deleteStockChecklist(checklist.id!);
        _loadChecklists();
        _showSuccessSnackBar('Checklist supprimée');
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

  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'DAILY': return 'Quotidien';
      case 'WEEKLY': return 'Hebdomadaire';
      case 'MONTHLY': return 'Mensuel';
      default: return frequency;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

