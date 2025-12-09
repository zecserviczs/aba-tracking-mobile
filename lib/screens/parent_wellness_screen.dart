import 'package:flutter/material.dart';

class ParentWellnessScreen extends StatefulWidget {
  const ParentWellnessScreen({Key? key}) : super(key: key);

  @override
  State<ParentWellnessScreen> createState() => _ParentWellnessScreenState();
}

class _ParentWellnessScreenState extends State<ParentWellnessScreen> {
  String currentView = 'dashboard';
  
  // Statistiques
  Map<String, int> stats = {
    'daysStreak': 7,
    'gratitudeCount': 12,
    'pausesTaken': 5,
    'resourcesViewed': 8,
  };

  // Journal de gratitude
  String newGratitude = '';
  String currentMood = 'good';
  List<Map<String, dynamic>> gratitudeEntries = [];

  // Burnout
  List<Map<String, dynamic>> burnoutQuestions = [
    {'question': 'Je me sens épuisé(e) physiquement et émotionnellement', 'score': 0},
    {'question': 'J\'ai du mal à trouver du temps pour moi', 'score': 0},
    {'question': 'Je me sens dépassé(e) par les responsabilités', 'score': 0},
    {'question': 'J\'ai des difficultés à dormir', 'score': 0},
    {'question': 'Je ressens de l\'irritabilité ou de l\'anxiété', 'score': 0},
    {'question': 'J\'ai perdu ma motivation ou mon enthousiasme', 'score': 0},
    {'question': 'Je me sens isolé(e) socialement', 'score': 0},
    {'question': 'J\'ai du mal à célébrer les petites victoires', 'score': 0},
  ];
  int burnoutScore = 0;

  @override
  void initState() {
    super.initState();
    _loadGratitudeEntries();
  }

  void _loadGratitudeEntries() {
    gratitudeEntries = [
      {
        'id': 1,
        'date': DateTime.now(),
        'content': 'Aujourd\'hui, mon enfant a regardé dans mes yeux et a souri',
        'mood': 'excellent'
      },
      {
        'id': 2,
        'date': DateTime.now().subtract(Duration(days: 1)),
        'content': 'Il a mangé seul pour la première fois',
        'mood': 'good'
      },
    ];
  }

  void _addGratitude() {
    if (newGratitude.trim().isEmpty) return;

    setState(() {
      gratitudeEntries.insert(0, {
        'id': gratitudeEntries.length + 1,
        'date': DateTime.now(),
        'content': newGratitude,
        'mood': currentMood,
      });
      newGratitude = '';
      stats['gratitudeCount'] = stats['gratitudeCount']! + 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✨ Votre victoire a été enregistrée !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _calculateBurnoutScore() {
    int total = 0;
    for (var question in burnoutQuestions) {
      total += (question['score'] as int);
    }
    
    int maxScore = burnoutQuestions.length * 5;
    setState(() {
      burnoutScore = ((total / maxScore) * 100).round();
    });
  }

  Map<String, dynamic> _getBurnoutLevel() {
    if (burnoutScore < 25) {
      return {
        'label': 'Vous allez bien',
        'color': Colors.green[700]!,
        'advice': 'Continuez à prendre soin de vous. Maintenez vos bonnes habitudes.'
      };
    } else if (burnoutScore < 50) {
      return {
        'label': 'Fatigue modérée',
        'color': Colors.orange[700]!,
        'advice': 'Prenez plus de pauses. N\'hésitez pas à demander de l\'aide.'
      };
    } else if (burnoutScore < 75) {
      return {
        'label': 'Risque de burnout',
        'color': Colors.red[700]!,
        'advice': 'Il est important de consulter un professionnel et de prendre du temps pour vous.'
      };
    } else {
      return {
        'label': 'Burnout sévère',
        'color': Colors.red[900]!,
        'advice': 'Consultez immédiatement un professionnel. Votre santé est prioritaire.'
      };
    }
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'excellent': return '😊';
      case 'good': return '🙂';
      case 'neutral': return '😐';
      case 'difficult': return '😔';
      case 'hard': return '😰';
      default: return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'excellent': return Colors.green[400]!;
      case 'good': return Colors.lightGreen[400]!;
      case 'neutral': return Colors.orange[400]!;
      case 'difficult': return Colors.deepOrange[400]!;
      case 'hard': return Colors.red[400]!;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Parents'),
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
        child: _buildCurrentView(),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'gratitude':
        return _buildGratitudeView();
      case 'burnout':
        return _buildBurnoutView();
      case 'resources':
        return _buildResourcesView();
      case 'relaxation':
        return _buildRelaxationView();
      case 'community':
        return _buildCommunityView();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message d'accueil
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.pink[400], size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prenez soin de vous',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Votre bien-être est essentiel pour accompagner votre enfant',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 24),

          // Statistiques
          Text(
            'Votre suivi',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildStatCard('Jours consécutifs', stats['daysStreak']!, Icons.local_fire_department, Colors.orange),
              _buildStatCard('Victoires', stats['gratitudeCount']!, Icons.auto_awesome, Colors.amber),
              _buildStatCard('Pauses prises', stats['pausesTaken']!, Icons.self_improvement, Colors.purple),
              _buildStatCard('Ressources', stats['resourcesViewed']!, Icons.book, Colors.green),
            ],
          ),

          SizedBox(height: 32),

          // Actions
          Text(
            'Comment puis-je vous aider ?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          SizedBox(height: 16),

          _buildActionCard(
            'Journal de gratitude',
            'Notez vos victoires et moments positifs',
            Icons.auto_awesome,
            Colors.yellow[700]!,
            () => setState(() => currentView = 'gratitude'),
          ),

          _buildActionCard(
            'Évaluation bien-être',
            'Évaluez votre niveau de fatigue',
            Icons.favorite_border,
            Colors.pink[700]!,
            () => setState(() => currentView = 'burnout'),
          ),

          _buildActionCard(
            'Ressources & guides',
            'Articles, vidéos et conseils pratiques',
            Icons.menu_book,
            Colors.green[700]!,
            () => setState(() => currentView = 'resources'),
          ),

          _buildActionCard(
            'Pause & détente',
            'Exercices de relaxation et méditation',
            Icons.spa,
            Colors.purple[400]!,
            () => setState(() => currentView = 'relaxation'),
          ),

          _buildActionCard(
            'Communauté',
            'Échanger avec d\'autres parents',
            Icons.groups,
            Colors.blue[700]!,
            () => setState(() => currentView = 'community'),
          ),

          // Contacts d'urgence
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[300]!, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.phone_in_talk, color: Colors.red[700], size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Contacts d\'urgence',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[900],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildEmergencyNumber('SOS Amitié', '09 72 39 40 50'),
                SizedBox(height: 8),
                _buildEmergencyNumber('Fil Santé Jeunes', '0800 235 236'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          SizedBox(height: 12),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
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
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
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

  Widget _buildEmergencyNumber(String service, String number) {
    return Row(
      children: [
        Icon(Icons.phone, color: Colors.red[700], size: 18),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 14),
              children: [
                TextSpan(
                  text: '$service: ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: number,
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGratitudeView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text('Retour'),
            onPressed: () => setState(() => currentView = 'dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
            ),
          ),

          SizedBox(height: 24),

          // Formulaire
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quelle victoire célébrez-vous aujourd\'hui ? ✨',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Même les plus petites réussites comptent !',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                
                SizedBox(height: 20),

                Text('Comment vous sentez-vous ?', style: TextStyle(fontWeight: FontWeight.w500)),
                SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ['excellent', 'good', 'neutral', 'difficult', 'hard'].map((mood) {
                    return GestureDetector(
                      onTap: () => setState(() => currentMood = mood),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentMood == mood ? Colors.pink[400]! : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: currentMood == mood ? Colors.pink[50] : Colors.white,
                        ),
                        child: Text(
                          _getMoodEmoji(mood),
                          style: TextStyle(fontSize: 28),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 20),

                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Exemple : Aujourd\'hui, mon enfant a essayé un nouvel aliment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pink[400]!, width: 2),
                    ),
                  ),
                  onChanged: (value) => newGratitude = value,
                ),

                SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Enregistrer cette victoire'),
                    onPressed: _addGratitude,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[400],
                      padding: EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                ],
              ),
            ),

          SizedBox(height: 32),

          Text(
            'Vos victoires récentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.pink[700],
            ),
          ),
          SizedBox(height: 16),

          ...gratitudeEntries.map((entry) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border(
                  left: BorderSide(color: Colors.amber[400]!, width: 4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getMoodColor(entry['mood']),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getMoodEmoji(entry['mood']),
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '${entry['date'].day}/${entry['date'].month}/${entry['date'].year}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    entry['content'],
                    style: TextStyle(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            );
          }).toList(),
          ],
        ),
    );
  }

  Widget _buildBurnoutView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text('Retour'),
            onPressed: () => setState(() => currentView = 'dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
            ),
          ),

          SizedBox(height: 24),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Évaluez votre niveau de fatigue sur une échelle de 0 (pas du tout) à 5 (énormément) :',
              style: TextStyle(color: Colors.blue[900]),
            ),
          ),

          SizedBox(height: 20),

          ...burnoutQuestions.asMap().entries.map((entry) {
            return _buildBurnoutQuestion(entry.key, entry.value);
          }).toList(),

          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.assessment),
              label: Text('Voir mes résultats'),
              onPressed: _calculateBurnoutScore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink[400],
                padding: EdgeInsets.all(16),
              ),
            ),
          ),

          if (burnoutScore > 0) ...[
            SizedBox(height: 32),
            _buildBurnoutResult(),
          ],
        ],
      ),
    );
  }

  Widget _buildBurnoutQuestion(int index, Map<String, dynamic> question) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question['question'],
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (score) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    question['score'] = score;
                  });
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: question['score'] == score ? Colors.pink[400] : Colors.white,
                    border: Border.all(
                      color: question['score'] == score ? Colors.pink[400]! : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: question['score'] == score ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBurnoutResult() {
    final level = _getBurnoutLevel();
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: level['color'],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$burnoutScore%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  level['label'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber[700], size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    level['advice'],
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesView() {
    final resources = [
      {
        'title': 'Gérer le stress parental',
        'type': 'Article',
        'category': 'Bien-être',
        'description': 'Techniques pratiques pour réduire le stress quotidien',
        'duration': '5 min',
        'icon': Icons.article,
      },
      {
        'title': 'Méditation guidée',
        'type': 'Audio',
        'category': 'Relaxation',
        'description': 'Séance de relaxation de 10 minutes',
        'duration': '10 min',
        'icon': Icons.headphones,
      },
      {
        'title': 'Comprendre l\'autisme',
        'type': 'Guide',
        'category': 'Éducation',
        'description': 'Guide pratique pour mieux comprendre',
        'duration': '30 min',
        'icon': Icons.menu_book,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text('Retour'),
            onPressed: () => setState(() => currentView = 'dashboard'),
          ),

          SizedBox(height: 24),

          Text(
            'Ressources & Guides',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),

          SizedBox(height: 16),

          ...resources.map((resource) {
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(resource['icon'] as IconData, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              resource['category'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            resource['title'] as String,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            resource['description'] as String,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                resource['duration'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {},
                                child: Text('Consulter'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRelaxationView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text('Retour'),
            onPressed: () => setState(() => currentView = 'dashboard'),
          ),

          SizedBox(height: 24),

          Text(
            'Pause & Détente',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple[700],
            ),
          ),

          SizedBox(height: 16),

          _buildRelaxationCard(
            '🧘‍♀️ Respiration apaisante',
            '2 minutes',
            'Exercice simple de cohérence cardiaque',
            ['Inspirez profondément pendant 5 secondes', 'Retenez 2 secondes', 'Expirez lentement pendant 7 secondes', 'Répétez 5 fois'],
          ),

          _buildRelaxationCard(
            '🎵 Musique relaxante',
            '10 minutes',
            'Playlist apaisante pour vous détendre',
            [],
          ),

          _buildRelaxationCard(
            '📖 Méditation guidée',
            '15 minutes',
            'Séance de méditation pour parents',
            [],
          ),
        ],
      ),
    );
  }

  Widget _buildRelaxationCard(String title, String duration, String description, List<String> steps) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.purple[700],
              ),
            ),
            SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.grey[600])),
            if (steps.isNotEmpty) ...[
              SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text('${entry.key + 1}. ${entry.value}', style: TextStyle(fontSize: 13)),
                );
              }).toList(),
            ],
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.play_circle),
              label: Text('Démarrer'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: Icon(Icons.arrow_back),
            label: Text('Retour'),
            onPressed: () => setState(() => currentView = 'dashboard'),
          ),

          SizedBox(height: 24),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'La communauté est en développement. Bientôt disponible !',
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          Text(
            'Témoignages inspirants',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 16),

          _buildTestimonial(
            'Marie, maman de Lucas (8 ans)',
            'Il y a 2 jours',
            'Après 3 mois d\'utilisation, je vois une vraie différence. Les routines visuelles ont transformé nos matinées.',
            24,
            8,
          ),

          _buildTestimonial(
            'Sophie, maman d\'Emma (6 ans)',
            'Il y a 5 jours',
            'N\'oubliez pas de célébrer chaque petite victoire. Aujourd\'hui, Emma a dit "merci" spontanément. C\'est énorme ! 💙',
            42,
            15,
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonial(String author, String date, String content, int likes, int comments) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Icon(Icons.person, color: Colors.blue[700]),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author, style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(content, style: TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic)),
            SizedBox(height: 12),
            Row(
              children: [
                Text('❤️ $likes', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                SizedBox(width: 16),
                Text('💬 $comments commentaires', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


