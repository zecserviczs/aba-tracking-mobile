import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/admin_models.dart';
import '../../services/admin_service.dart';

class AdminKnowledgeScreen extends StatefulWidget {
  const AdminKnowledgeScreen({super.key});

  @override
  State<AdminKnowledgeScreen> createState() => _AdminKnowledgeScreenState();
}

class _AdminKnowledgeScreenState extends State<AdminKnowledgeScreen> {
  final AdminService _adminService = AdminService();
  List<KnowledgeBaseEntry> _knowledgeEntries = [];
  bool _isLoading = true;
  String? _error;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadKnowledgeEntries();
  }

  Future<void> _loadKnowledgeEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final entries = await _adminService.getAllKnowledgeEntries();
      setState(() {
        _knowledgeEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Base de Connaissances RAG'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddKnowledgeDialog(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadKnowledgeEntries,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _buildKnowledgeList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher dans les connaissances...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) {
          setState(() {
            _searchTerm = value;
          });
        },
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadKnowledgeEntries,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeList() {
    final filteredEntries = _searchTerm.isEmpty
        ? _knowledgeEntries
        : _knowledgeEntries.where((entry) =>
            entry.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            entry.content.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            (entry.category?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false) ||
            (entry.keywords?.toLowerCase().contains(_searchTerm.toLowerCase()) ?? false)).toList();

    if (filteredEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _searchTerm.isEmpty ? 'Aucune connaissance trouvée' : 'Aucun résultat pour "$_searchTerm"',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
            if (_searchTerm.isEmpty) ...[
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => _showAddKnowledgeDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une connaissance'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadKnowledgeEntries,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = filteredEntries[index];
          return _buildKnowledgeCard(entry);
        },
      ),
    );
  }

  Widget _buildKnowledgeCard(KnowledgeBaseEntry entry) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.school, color: Colors.green.shade700),
        ),
        title: Text(
          entry.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.category != null) ...[
              SizedBox(height: 4.h),
              Chip(
                label: Text(
                  entry.category!,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white),
                ),
                backgroundColor: Colors.green.shade600,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
            if (entry.createdAt != null) ...[
              SizedBox(height: 4.h),
              Text(
                'Créé le ${_formatDate(entry.createdAt!)}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.keywords != null) ...[
                  Text(
                    'Mots-clés:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 4.w,
                    children: entry.keywords!.split(',').map((keyword) => Chip(
                      label: Text(
                        keyword.trim(),
                        style: TextStyle(fontSize: 10.sp),
                      ),
                      backgroundColor: Colors.grey.shade200,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                  SizedBox(height: 12.h),
                ],
                Text(
                  'Contenu:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  entry.content,
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _showEditKnowledgeDialog(entry),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Modifier'),
                    ),
                    SizedBox(width: 8.w),
                    TextButton.icon(
                      onPressed: () => _deleteKnowledgeEntry(entry),
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddKnowledgeDialog() {
    showDialog(
      context: context,
      builder: (context) => KnowledgeEntryDialog(
        onSave: (entry) async {
          try {
            await _adminService.addKnowledgeEntry(entry);
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connaissance ajoutée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadKnowledgeEntries();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditKnowledgeDialog(KnowledgeBaseEntry entry) {
    showDialog(
      context: context,
      builder: (context) => KnowledgeEntryDialog(
        entry: entry,
        onSave: (updatedEntry) async {
          try {
            await _adminService.updateKnowledgeEntry(entry.id!, updatedEntry);
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Connaissance modifiée avec succès'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadKnowledgeEntries();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  void _deleteKnowledgeEntry(KnowledgeBaseEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${entry.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _adminService.deleteKnowledgeEntry(entry.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Connaissance supprimée avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadKnowledgeEntries();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

class KnowledgeEntryDialog extends StatefulWidget {
  final KnowledgeBaseEntry? entry;
  final Function(KnowledgeBaseEntry) onSave;

  const KnowledgeEntryDialog({
    super.key,
    this.entry,
    required this.onSave,
  });

  @override
  State<KnowledgeEntryDialog> createState() => _KnowledgeEntryDialogState();
}

class _KnowledgeEntryDialogState extends State<KnowledgeEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _categoryController = TextEditingController();
  final _keywordsController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _categoryController.text = widget.entry!.category ?? '';
      _keywordsController.text = widget.entry!.keywords ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _categoryController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Ajouter une connaissance' : 'Modifier la connaissance'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Titre requis';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _keywordsController,
                decoration: const InputDecoration(
                  labelText: 'Mots-clés (séparés par des virgules)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contenu requis';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveEntry,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.entry == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final entry = KnowledgeBaseEntry(
      id: widget.entry?.id,
      title: _titleController.text,
      content: _contentController.text,
      category: _categoryController.text.isEmpty ? null : _categoryController.text,
      keywords: _keywordsController.text.isEmpty ? null : _keywordsController.text,
    );

    widget.onSave(entry);
  }
}


