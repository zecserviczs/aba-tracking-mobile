import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_drawer.dart';

class SocialScenariosScreen extends ConsumerStatefulWidget {
  const SocialScenariosScreen({super.key});

  @override
  ConsumerState<SocialScenariosScreen> createState() => _SocialScenariosScreenState();
}

class _SocialScenariosScreenState extends ConsumerState<SocialScenariosScreen> {
  String? _userType;
  bool _isLoading = true;
  
  final List<SocialScenario> _scenarios = [
    SocialScenario(
      title: 'Demander de l\'aide',
      description: 'Comment demander de l\'aide de manière appropriée',
      steps: [
        'Identifier le problème',
        'S\'approcher de la personne',
        'Dire "Excusez-moi"',
        'Expliquer le problème',
        'Demander de l\'aide poliment',
        'Remercier la personne',
      ],
      ageGroup: '5-12 ans',
    ),
    SocialScenario(
      title: 'Partager avec les autres',
      description: 'Apprendre à partager ses jouets et ses affaires',
      steps: [
        'Voir que quelqu\'un veut jouer',
        'Proposer de partager',
        'Expliquer les règles du jeu',
        'Jouer ensemble',
        'Remercier l\'autre enfant',
      ],
      ageGroup: '3-8 ans',
    ),
    SocialScenario(
      title: 'Gérer la frustration',
      description: 'Techniques pour gérer les émotions difficiles',
      steps: [
        'Reconnaître les signes de frustration',
        'Respirer profondément',
        'Compter jusqu\'à 10',
        'Demander de l\'aide si nécessaire',
        'Essayer une solution alternative',
      ],
      ageGroup: '6-15 ans',
    ),
    SocialScenario(
      title: 'Faire des demandes appropriées',
      description: 'Comment faire des demandes de manière respectueuse',
      steps: [
        'Attendre le bon moment',
        'Utiliser un ton calme',
        'Dire "S\'il vous plaît"',
        'Expliquer pourquoi c\'est important',
        'Accepter la réponse',
      ],
      ageGroup: '4-12 ans',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final prefs = await SharedPreferences.getInstance();
    final userType = prefs.getString('userType');
    setState(() {
      _userType = userType;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final isProfessional = _userType == 'professional';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scénarios Sociaux',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: isProfessional ? Colors.green[700] : Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        actions: [
          if (isProfessional)
            IconButton(
              icon: Icon(Icons.add),
              onPressed: _showAddScenarioDialog,
              tooltip: 'Ajouter un scénario',
            ),
        ],
      ),
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header avec informations
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scénarios Sociaux',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_scenarios.length} scénario${_scenarios.length > 1 ? 's' : ''} disponible${_scenarios.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 40,
                  ),
                ],
              ),
            ),
            
            // Liste des scénarios
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: _scenarios.length,
                itemBuilder: (context, index) {
                  final scenario = _scenarios[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _showScenarioDetails(scenario),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.blue.withOpacity(0.7),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      Icons.psychology,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          scenario.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          scenario.description,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            scenario.ageGroup,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.visibility),
                                        onPressed: () => _showScenarioDetails(scenario),
                                        tooltip: 'Voir les détails',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.picture_as_pdf),
                                        onPressed: () => _generatePDF(scenario),
                                        tooltip: 'Générer PDF',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddScenarioDialog,
        child: Icon(Icons.add),
        tooltip: 'Ajouter un scénario',
      ),
    );
  }

  void _showScenarioDetails(SocialScenario scenario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scenario.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                scenario.description,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Étapes :',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ...scenario.steps.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _generatePDF(scenario);
            },
            icon: Icon(Icons.picture_as_pdf),
            label: Text('Générer PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePDF(SocialScenario scenario) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Scénario Social',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      scenario.title,
                      style: pw.TextStyle(
                        fontSize: 18,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Description
              pw.Text(
                'Description :',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                scenario.description,
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              
              // Groupe d'âge
              pw.Row(
                children: [
                  pw.Text(
                    'Groupe d\'âge : ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Container(
                    padding: pw.EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue100,
                      borderRadius: pw.BorderRadius.circular(12),
                    ),
                    child: pw.Text(
                      scenario.ageGroup,
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.blue800,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              
              // Étapes
              pw.Text(
                'Étapes à suivre :',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              
              ...scenario.steps.asMap().entries.map((entry) {
                return pw.Padding(
                  padding: pw.EdgeInsets.only(bottom: 12),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 24,
                        height: 24,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue,
                          borderRadius: pw.BorderRadius.circular(12),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            '${entry.key + 1}',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Text(
                          entry.value,
                          style: pw.TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              
              pw.SizedBox(height: 30),
              
              // Pied de page
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Généré par ABA Tracking Mobile - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'scenario_social_${scenario.title.replaceAll(' ', '_')}.pdf',
    );
  }

  void _showAddScenarioDialog() {
    context.go('/create-social-scenario');
  }
}

class SocialScenario {
  final String title;
  final String description;
  final List<String> steps;
  final String ageGroup;

  SocialScenario({
    required this.title,
    required this.description,
    required this.steps,
    required this.ageGroup,
  });
}
