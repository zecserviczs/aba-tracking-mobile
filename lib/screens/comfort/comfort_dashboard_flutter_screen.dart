import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/comfort_service.dart';
import 'routines_flutter_screen.dart';
import 'comfort_items_flutter_screen.dart';

class ComfortDashboardFlutterScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ComfortDashboardFlutterScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ComfortDashboardFlutterScreen> createState() => _ComfortDashboardFlutterScreenState();
}

class _ComfortDashboardFlutterScreenState extends State<ComfortDashboardFlutterScreen> {
  bool isLoading = true;
  Map<String, dynamic> stats = {
    'totalRoutines': 0,
    'totalComfortItems': 0,
    'criticalItems': 0,
    'itemsNeedingReplacement': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);
    
    try {
      // Données simulées pour l'instant
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        stats = {
          'totalRoutines': 5,
          'totalComfortItems': 12,
          'criticalItems': 3,
          'itemsNeedingReplacement': 2,
        };
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/parent-dashboard'),
        ),
        title: Text('Confort - ${widget.childName}'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadStats,
            color: Colors.white,
          ),
        ],
      ),
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistiques
                    Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Routines',
                            stats['totalRoutines'].toString(),
                            Colors.green,
                            Icons.schedule,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Éléments',
                            stats['totalComfortItems'].toString(),
                            Colors.teal,
                            Icons.favorite,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Critiques',
                            stats['criticalItems'].toString(),
                            Colors.orange,
                            Icons.warning,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'À remplacer',
                            stats['itemsNeedingReplacement'].toString(),
                            Colors.amber,
                            Icons.inventory,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 32),

                    // Actions
                    Text(
                      'Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    _buildActionCard(
                      'Gérer les routines',
                      'Créer et organiser les routines quotidiennes',
                      Icons.schedule,
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoutinesFlutterScreen(
                              childId: widget.childId,
                              childName: widget.childName,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 12),

                    _buildActionCard(
                      'Éléments de confort',
                      'Gérer les objets et éléments rassurants',
                      Icons.favorite,
                      Colors.teal,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComfortItemsFlutterScreen(
                              childId: widget.childId,
                              childName: widget.childName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}


