import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  Future<String?> _getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userType');
  }

  Future<List<String>> _getUserRoles() async {
    final prefs = await SharedPreferences.getInstance();
    final rolesString = prefs.getString('userRoles');
    if (rolesString != null) {
      return rolesString.split(',');
    }
    return [];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([_getUserType(), _getUserRoles()]).then((results) => {
        'userType': results[0],
        'userRoles': results[1],
      }),
      builder: (context, snapshot) {
        final userType = snapshot.data?['userType'];
        final userRoles = snapshot.data?['userRoles'] as List<String>? ?? [];
        final isProfessional = userType == 'professional';
        final isAdmin = userRoles.contains('ADMIN');
        
        return Drawer(
      child: Column(
        children: [
          // Header avec informations utilisateur
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProfessional ? [
                  Colors.green[700]!,
                  Colors.green[500]!,
                ] : [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user?.username ?? 'Utilisateur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.username ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Menu pour professionnels
                if (isProfessional) ...[
                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard,
                    title: 'Tableau de Bord',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.child_care,
                    title: 'Mes Patients',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.auto_stories,
                    title: 'Scénarios Sociaux',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/social-scenarios');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.add_circle,
                    title: 'Créer un Scénario',
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateScenarioDialog(context);
                    },
                  ),
                ] else ...[
                  // Menu pour parents
                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/parent-dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.child_care,
                    title: 'Mes Enfants',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/parent-dashboard');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.psychology,
                    title: 'Intelligence Artificielle',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/ai-analysis');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.chat,
                    title: 'Assistant IA ABA',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/rag-chat');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.auto_stories,
                    title: 'Scénarios Sociaux',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/social-scenarios');
                    },
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.star,
                    title: 'Abonnements',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/subscriptions');
                    },
                  ),
                ],
                
                // Menu d'administration (visible uniquement pour les admins)
                if (isAdmin) ...[
                  Divider(),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.admin_panel_settings,
                    title: 'Administration',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/admin');
                    },
                  ),
                ],
                
                Divider(),
                
                _buildMenuItem(
                  context: context,
                  icon: Icons.settings,
                  title: 'Paramètres',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Ajouter une page de paramètres
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.help,
                  title: 'Aide',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.info,
                  title: 'À propos',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Footer avec bouton de déconnexion
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text(
                    'Déconnexion',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      hoverColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Aide'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Comment utiliser l\'application :'),
            SizedBox(height: 16),
            Text('• Dashboard : Consultez la liste de vos enfants'),
            Text('• Observations : Ajoutez et consultez les observations comportementales'),
            Text('• Analyses : Visualisez les tendances et statistiques'),
            Text('• Paramètres : Configurez votre profil'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ABA Tracking Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.child_care,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        Text('Application mobile pour le suivi des comportements ABA.'),
        SizedBox(height: 16),
        Text('Développée avec Flutter et connectée à un backend Spring Boot.'),
      ],
    );
  }

  void _showCreateScenarioDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un Scénario Social'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Titre du scénario',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Âge cible',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implémenter la création du scénario
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fonctionnalité en cours de développement'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }
}
