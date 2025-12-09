import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/stock_models.dart';
import '../../models/child_model.dart';
import '../../services/stock_service.dart';

class StockDashboardScreen extends StatefulWidget {
  final Child child;

  const StockDashboardScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<StockDashboardScreen> createState() => _StockDashboardScreenState();
}

class _StockDashboardScreenState extends State<StockDashboardScreen> {
  StockStats? _stats;
  List<StockChecklist> _scheduledChecklists = [];
  List<StockChecklist> _overdueChecklists = [];
  List<StockCheckItem> _itemsNeedingRestock = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);

      final stats = await StockService.getStockStats(widget.child.id!);
      final scheduled =
          await StockService.getScheduledForToday(widget.child.id!);
      final overdue = await StockService.getOverdueChecklists(widget.child.id!);
      final restock =
          await StockService.getItemsNeedingRestock(widget.child.id!);

      setState(() {
        _stats = stats;
        _scheduledChecklists = scheduled;
        _overdueChecklists = overdue;
        _itemsNeedingRestock = restock;
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
        title: Text('Vérifications de stock - ${widget.child.name}'),
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
                    _buildStatsCards(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildOverdueSection(),
                    const SizedBox(height: 24),
                    _buildScheduledSection(),
                    const SizedBox(height: 24),
                    _buildRestockSection(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle checklist'),
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
                'Checklists actives',
                _stats!.totalChecklists.toString(),
                Icons.checklist,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'En retard',
                _stats!.overdueChecklists.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Éléments vérifiés',
                '${_stats!.checkedItems}/${_stats!.totalItems}',
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'À réapprovisionner',
                _stats!.itemsNeedingRestock.toString(),
                Icons.shopping_cart,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildProgressIndicator(),
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

  Widget _buildProgressIndicator() {
    if (_stats == null || _stats!.totalItems == 0)
      return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progression des vérifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_stats!.completionPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _stats!.completionPercentage / 100.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _stats!.completionPercentage >= 80
                    ? Colors.green
                    : _stats!.completionPercentage >= 50
                        ? Colors.orange
                        : Colors.red,
              ),
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
                'Nouvelle checklist',
                Icons.add_task,
                Colors.blue,
                () => context
                    .push('/children/${widget.child.id}/stock/checklists/new'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Vérifier maintenant',
                Icons.checklist_rtl,
                Colors.green,
                () => _showQuickCheckDialog(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Depuis éléments confort',
                Icons.auto_awesome,
                Colors.purple,
                () => context.push(
                    '/children/${widget.child.id}/stock/checklists/from-comfort'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Toutes les checklists',
                Icons.list,
                Colors.teal,
                () => context
                    .push('/children/${widget.child.id}/stock/checklists'),
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

  Widget _buildOverdueSection() {
    if (_overdueChecklists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '⚠️ Checklists en retard',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            TextButton(
              onPressed: () => context.push(
                  '/children/${widget.child.id}/stock/checklists/overdue'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._overdueChecklists
            .take(3)
            .map((checklist) => _buildChecklistCard(checklist, true)),
      ],
    );
  }

  Widget _buildScheduledSection() {
    if (_scheduledChecklists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📅 Programmées aujourd\'hui',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push(
                  '/children/${widget.child.id}/stock/checklists/scheduled'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._scheduledChecklists
            .take(3)
            .map((checklist) => _buildChecklistCard(checklist, false)),
      ],
    );
  }

  Widget _buildRestockSection() {
    if (_itemsNeedingRestock.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '🛒 À réapprovisionner',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/children/${widget.child.id}/stock/restock'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._itemsNeedingRestock
            .take(5)
            .map((item) => _buildRestockItemCard(item)),
      ],
    );
  }

  Widget _buildChecklistCard(StockChecklist checklist, bool isOverdue) {
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
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOverdue) const Icon(Icons.warning, color: Colors.red),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _completeChecklist(checklist),
            ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => context.push(
                  '/children/${widget.child.id}/stock/checklists/${checklist.id}'),
            ),
          ],
        ),
        onTap: () => context.push(
            '/children/${widget.child.id}/stock/checklists/${checklist.id}'),
      ),
    );
  }

  Widget _buildRestockItemCard(StockCheckItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.status.color,
          child: Icon(
            item.status.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
            'Stock actuel: ${item.currentStock} ${item.unit} (minimum: ${item.minimumStock})'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editStockItem(item),
            ),
          ],
        ),
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
                leading: const Icon(Icons.add_task),
                title: const Text('Nouvelle checklist'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                      '/children/${widget.child.id}/stock/checklists/new');
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome),
                title: const Text('Depuis éléments de confort'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(
                      '/children/${widget.child.id}/stock/checklists/from-comfort');
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist_rtl),
                title: const Text('Vérification rapide'),
                onTap: () {
                  Navigator.pop(context);
                  _showQuickCheckDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickCheckDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vérification rapide'),
        content: const Text(
            'Cette fonctionnalité vous permettra de faire une vérification rapide des éléments essentiels.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la vérification rapide
            },
            child: const Text('Commencer'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeChecklist(StockChecklist checklist) async {
    try {
      await StockService.completeStockChecklist(checklist.id!);
      _loadData();
      _showSuccessSnackBar('Checklist complétée !');
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  void _editStockItem(StockCheckItem item) {
    // TODO: Implémenter l'édition rapide du stock
    _showErrorSnackBar('Fonctionnalité à venir');
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
      case 'DAILY':
        return 'Quotidien';
      case 'WEEKLY':
        return 'Hebdomadaire';
      case 'MONTHLY':
        return 'Mensuel';
      default:
        return frequency;
    }
  }
}




