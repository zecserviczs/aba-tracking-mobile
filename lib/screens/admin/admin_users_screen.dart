import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/admin_models.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  final AdminService _adminService = AdminService();
  late TabController _tabController;

  List<AdminUser> _allUsers = [];
  List<AdminUser> _parents = [];
  List<AdminUser> _professionals = [];
  bool _isLoading = true;
  String? _error;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final futures = await Future.wait([
        _adminService.getAllUsers(),
        _adminService.getParents(),
        _adminService.getProfessionals(),
      ]);

      setState(() {
        _allUsers = futures[0];
        _parents = futures[1];
        _professionals = futures[2];
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
        title: const Text('Gestion des Utilisateurs'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Tous', icon: Icon(Icons.people)),
            Tab(text: 'Parents', icon: Icon(Icons.family_restroom)),
            Tab(text: 'Professionnels', icon: Icon(Icons.medical_services)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
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
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildUsersList(_allUsers),
                          _buildUsersList(_parents),
                          _buildUsersList(_professionals),
                        ],
                      ),
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
          hintText: 'Rechercher un utilisateur...',
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
            onPressed: _loadUsers,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<AdminUser> users) {
    final filteredUsers = _searchTerm.isEmpty
        ? users
        : users
            .where((user) =>
                user.email.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                user.username.toLowerCase().contains(_searchTerm.toLowerCase()))
            .toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              _searchTerm.isEmpty
                  ? 'Aucun utilisateur trouvé'
                  : 'Aucun résultat pour "$_searchTerm"',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserTypeColor(user.userType),
          child: Icon(
            _getUserTypeIcon(user.userType),
            color: Colors.white,
          ),
        ),
        title: Text(
          user.username,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 4.w,
              children: user.roles
                  .map((role) => Chip(
                        label: Text(
                          role,
                          style:
                              TextStyle(fontSize: 10.sp, color: Colors.white),
                        ),
                        backgroundColor: _getRoleColor(role),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ))
                  .toList(),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handleUserAction(user, action),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'activate',
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Activer'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'deactivate',
              child: ListTile(
                leading: Icon(Icons.cancel, color: Colors.orange),
                title: Text('Désactiver'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Supprimer'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showUserDetails(user),
      ),
    );
  }

  Color _getUserTypeColor(String userType) {
    switch (userType.toLowerCase()) {
      case 'parent':
        return Colors.green;
      case 'professional':
        return Colors.blue;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getUserTypeIcon(String userType) {
    switch (userType.toLowerCase()) {
      case 'parent':
        return Icons.family_restroom;
      case 'professional':
        return Icons.medical_services;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'PARENT':
        return Colors.green;
      case 'PROF':
        return Colors.blue;
      case 'ADMIN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleUserAction(AdminUser user, String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmer l\'action'),
        content: Text(
            'Êtes-vous sûr de vouloir ${_getActionText(action)} ${user.username} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _executeUserAction(user, action);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _getActionColor(action),
            ),
            child: Text(_getActionText(action)),
          ),
        ],
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'activate':
        return 'activer';
      case 'deactivate':
        return 'désactiver';
      case 'delete':
        return 'supprimer';
      default:
        return action;
    }
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'activate':
        return Colors.green;
      case 'deactivate':
        return Colors.orange;
      case 'delete':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Future<void> _executeUserAction(AdminUser user, String action) async {
    try {
      final request = UserManagementRequest(
        email: user.email,
        isActive: action == 'activate'
            ? true
            : action == 'deactivate'
                ? false
                : null,
      );

      final message =
          await _adminService.manageUser(user.email, action, request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers(); // Recharger la liste
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
  }

  void _showUserDetails(AdminUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${user.username}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Nom d\'utilisateur', user.username),
            _buildDetailRow('Type', user.userType),
            _buildDetailRow('Rôles', user.roles.join(', ')),
            _buildDetailRow(
                'Statut', user.isActive == true ? 'Actif' : 'Inactif'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        ],
      ),
    );
  }
}




