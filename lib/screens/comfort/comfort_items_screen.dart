import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/comfort_models.dart';
import '../../models/child_model.dart';
import '../../services/comfort_service.dart';

class ComfortItemsScreen extends StatefulWidget {
  final Child child;

  const ComfortItemsScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ComfortItemsScreen> createState() => _ComfortItemsScreenState();
}

class _ComfortItemsScreenState extends State<ComfortItemsScreen>
    with TickerProviderStateMixin {
  List<ComfortItem> _items = [];
  List<ComfortCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ComfortItemType? _selectedType;
  int? _selectedCategory;
  ComfortLevel? _selectedLevel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final items = await ComfortService.getChildComfortItems(widget.child.id!);
      final categories = await ComfortService.getAllCategories();
      setState(() {
        _items = items;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Erreur lors du chargement des données: $e');
    }
  }

  List<ComfortItem> get _filteredItems {
    return _items.where((item) {
      if (_searchQuery.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedType != null && item.type != _selectedType) {
        return false;
      }
      if (_selectedCategory != null && item.categoryId != _selectedCategory) {
        return false;
      }
      if (_selectedLevel != null && item.comfortLevel != _selectedLevel) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/children/${widget.child.id}/comfort'),
        ),
        title: Text('Éléments de confort - ${widget.child.name}'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tous', icon: Icon(Icons.list)),
            Tab(text: 'Critiques', icon: Icon(Icons.priority_high)),
            Tab(text: 'Filtres', icon: Icon(Icons.filter_list)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAllItemsTab(),
                _buildCriticalItemsTab(),
                _buildFiltersTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push('/children/${widget.child.id}/comfort/items/new'),
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildAllItemsTab() {
    final filteredItems = _filteredItems;

    if (filteredItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun élément de confort configuré',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Ajoutez des éléments qui rassurent votre enfant',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) =>
                  _buildComfortItemCard(filteredItems[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCriticalItemsTab() {
    final criticalItems = _items
        .where((item) =>
            item.comfortLevel == ComfortLevel.CRITICAL ||
            item.comfortLevel == ComfortLevel.HIGH)
        .toList();

    if (criticalItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.priority_high, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun élément critique configuré',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Les éléments critiques sont essentiels au bien-être de votre enfant',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: criticalItems.length,
        itemBuilder: (context, index) =>
            _buildComfortItemCard(criticalItems[index]),
      ),
    );
  }

  Widget _buildFiltersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildTypeFilter(),
          const SizedBox(height: 24),
          _buildCategoryFilter(),
          const SizedBox(height: 24),
          _buildLevelFilter(),
          const SizedBox(height: 24),
          _buildClearFiltersButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Rechercher un élément...',
            prefixIcon: Icon(Icons.search),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type d\'élément',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Tous'),
              selected: _selectedType == null,
              onSelected: (selected) {
                setState(() => _selectedType = null);
              },
            ),
            ...ComfortItemType.values.map((type) => FilterChip(
                  label: Text(type.displayName),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() => _selectedType = selected ? type : null);
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Catégorie', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Toutes'),
              selected: _selectedCategory == null,
              onSelected: (selected) {
                setState(() => _selectedCategory = null);
              },
            ),
            ..._categories.map((category) => FilterChip(
                  label: Text(category.name),
                  selected: _selectedCategory == category.id,
                  onSelected: (selected) {
                    setState(() =>
                        _selectedCategory = selected ? category.id : null);
                  },
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Niveau d\'importance',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Tous'),
              selected: _selectedLevel == null,
              onSelected: (selected) {
                setState(() => _selectedLevel = null);
              },
            ),
            ...ComfortLevel.values.map((level) => FilterChip(
                  label: Text(level.displayName),
                  selected: _selectedLevel == level,
                  onSelected: (selected) {
                    setState(() => _selectedLevel = selected ? level : null);
                  },
                  selectedColor: level.color.withOpacity(0.3),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _searchQuery = '';
            _selectedType = null;
            _selectedCategory = null;
            _selectedLevel = null;
          });
        },
        child: const Text('Effacer tous les filtres'),
      ),
    );
  }

  Widget _buildComfortItemCard(ComfortItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: item.comfortLevel.color,
          child: Icon(
            _getComfortItemIcon(item.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.type.displayName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.flag, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.comfortLevel.displayName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            if (item.location != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    item.location!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.needsReplacement)
              const Icon(Icons.warning, color: Colors.orange, size: 20),
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _markAsUsed(item),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => context.push(
                  '/children/${widget.child.id}/comfort/items/${item.id}/edit'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(item),
            ),
          ],
        ),
        onTap: () => context
            .push('/children/${widget.child.id}/comfort/items/${item.id}'),
      ),
    );
  }

  Future<void> _markAsUsed(ComfortItem item) async {
    try {
      await ComfortService.markComfortItemAsUsed(item.id!);
      _loadData();
      _showSuccessSnackBar('Élément marqué comme utilisé');
    } catch (e) {
      _showErrorSnackBar('Erreur: $e');
    }
  }

  Future<void> _deleteItem(ComfortItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'élément'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${item.name}" ?'),
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
        await ComfortService.deleteComfortItem(item.id!);
        _loadData();
        _showSuccessSnackBar('Élément supprimé');
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

