import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/planning_models.dart';
import '../../services/planning_service.dart';

class PlanningScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const PlanningScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  DateTime selectedDate = DateTime.now();
  List<TimelineSlot> timeline = [];
  bool isLoading = false;
  
  // Bibliothèque de pictogrammes
  final List<Pictogram> availablePictograms = [
    Pictogram(id: 'wake', name: 'Réveil', icon: '☀️', color: '#ffeb3b', duration: 15),
    Pictogram(id: 'breakfast', name: 'Petit-déjeuner', icon: '🍳', color: '#ff9800', duration: 30),
    Pictogram(id: 'hygiene', name: 'Toilette', icon: '🚿', color: '#03a9f4', duration: 20),
    Pictogram(id: 'dress', name: 'S\'habiller', icon: '👔', color: '#9c27b0', duration: 15),
    Pictogram(id: 'school', name: 'École', icon: '🎓', color: '#4caf50', duration: 240),
    Pictogram(id: 'lunch', name: 'Déjeuner', icon: '🍽️', color: '#ff5722', duration: 45),
    Pictogram(id: 'play', name: 'Jeu libre', icon: '🎮', color: '#e91e63', duration: 60),
    Pictogram(id: 'homework', name: 'Devoirs', icon: '📚', color: '#795548', duration: 45),
    Pictogram(id: 'snack', name: 'Goûter', icon: '🍰', color: '#ff9800', duration: 15),
    Pictogram(id: 'activities', name: 'Activités', icon: '🧸', color: '#00bcd4', duration: 60),
    Pictogram(id: 'dinner', name: 'Dîner', icon: '🍴', color: '#f44336', duration: 45),
    Pictogram(id: 'bath', name: 'Bain', icon: '🛁', color: '#2196f3', duration: 30),
    Pictogram(id: 'bedtime', name: 'Coucher', icon: '😴', color: '#673ab7', duration: 20),
    Pictogram(id: 'story', name: 'Histoire', icon: '📖', color: '#607d8b', duration: 15),
    Pictogram(id: 'music', name: 'Musique', icon: '🎵', color: '#9c27b0', duration: 30),
    Pictogram(id: 'outdoor', name: 'Extérieur', icon: '🌳', color: '#4caf50', duration: 60),
    Pictogram(id: 'rest', name: 'Repos', icon: '💤', color: '#607d8b', duration: 30),
    Pictogram(id: 'therapy', name: 'Thérapie', icon: '🏥', color: '#00bcd4', duration: 60),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTimeline();
    _loadPlanning();
  }

  void _initializeTimeline() {
    timeline.clear();
    for (int hour = 7; hour <= 21; hour++) {
      timeline.add(TimelineSlot(time: '${hour.toString().padLeft(2, '0')}:00'));
      if (hour < 21) {
        timeline.add(TimelineSlot(time: '${hour.toString().padLeft(2, '0')}:30'));
      }
    }
  }

  Future<void> _loadPlanning() async {
    setState(() => isLoading = true);
    
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
      final planning = await PlanningService.getPlanningByDate(widget.childId, dateStr);
      
      if (planning != null) {
        setState(() {
          for (var activity in planning.activities) {
            final slotIndex = timeline.indexWhere((s) => s.time == activity.time);
            if (slotIndex != -1) {
              timeline[slotIndex].pictogram = Pictogram(
                id: activity.activityName.toLowerCase(),
                name: activity.activityName,
                icon: activity.icon,
                color: activity.color,
                duration: activity.duration,
              );
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _savePlanning() async {
    final activities = timeline
        .asMap()
        .entries
        .where((entry) => entry.value.pictogram != null)
        .map((entry) {
      final pictogram = entry.value.pictogram!;
      return {
        'time': entry.value.time,
        'activityName': pictogram.name,
        'icon': pictogram.icon,
        'color': pictogram.color,
        'duration': pictogram.duration,
        'orderIndex': entry.key,
      };
    }).toList();

    final planningData = {
      'date': DateFormat('yyyy-MM-dd').format(selectedDate),
      'activities': activities,
      'notes': '',
    };

    try {
      await PlanningService.savePlanning(widget.childId, planningData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Planning enregistré !'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning - ${widget.childName}'),
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
            icon: Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'Historique',
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: _showCopyDialog,
            tooltip: 'Copier',
            color: Colors.white,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePlanning,
            tooltip: 'Enregistrer',
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
            : Column(
              children: [
                // Sélecteur de date
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue[50],
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blue[700]),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            selectedDate = selectedDate.subtract(Duration(days: 1));
                            _initializeTimeline();
                            _loadPlanning();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            selectedDate = selectedDate.add(Duration(days: 1));
                            _initializeTimeline();
                            _loadPlanning();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    children: [
                      // Bibliothèque de pictogrammes
                      Container(
                        width: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 0),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              color: Colors.blue[700],
                              child: Row(
                                children: [
                                  Icon(Icons.widgets, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pictogrammes',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: availablePictograms.length,
                                itemBuilder: (context, index) {
                                  final pictogram = availablePictograms[index];
                                  return _buildDraggablePictogram(pictogram);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Timeline
                      Expanded(
                        child: Container(
                          color: Colors.grey[100],
                          child: ListView.builder(
                            itemCount: timeline.length,
                            itemBuilder: (context, index) {
                              return _buildTimelineSlot(index);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildDraggablePictogram(Pictogram pictogram) {
    return Draggable<Pictogram>(
      data: pictogram,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: _buildPictogramCard(pictogram, width: 140),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildPictogramCard(pictogram),
      ),
      child: _buildPictogramCard(pictogram),
    );
  }

  Widget _buildPictogramCard(Pictogram pictogram, {double? width}) {
    final color = _parseColor(pictogram.color);
    
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                pictogram.icon,
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  pictogram.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${pictogram.duration}min',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSlot(int index) {
    final slot = timeline[index];
    
    return DragTarget<Pictogram>(
      onAccept: (pictogram) {
        setState(() {
          timeline[index].pictogram = pictogram;
        });
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.blue[100]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Heure
              Container(
                width: 70,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot.time,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 8),
              
              // Contenu
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: slot.pictogram != null ? Colors.grey[50] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Colors.blue
                          : Colors.grey[300]!,
                      width: candidateData.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  child: slot.pictogram != null
                      ? _buildTimelinePictogram(slot.pictogram!, index)
                      : Center(
                          child: Text(
                            'Glissez une activité ici',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelinePictogram(Pictogram pictogram, int slotIndex) {
    final color = _parseColor(pictogram.color);
    
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text(
            pictogram.icon,
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pictogram.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '${pictogram.duration}min',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 18),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () {
              setState(() {
                timeline[slotIndex].pictogram = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  void _showHistory() {
    // TODO: Implémenter l'affichage de l'historique
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.history, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Historique des plannings'),
          ],
        ),
        content: Text('Fonctionnalité en cours de développement'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showCopyDialog() {
    DateTime? targetDate;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.content_copy, color: Colors.blue[700]),
            SizedBox(width: 12),
            Text('Copier le planning'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date source:'),
                SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(selectedDate),
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 16),
                Text('Date de destination:'),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(
                    targetDate != null
                        ? DateFormat('dd/MM/yyyy').format(targetDate!)
                        : 'Sélectionner une date',
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.add(Duration(days: 1)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        targetDate = picked;
                      });
                    }
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.content_copy),
            label: Text('Copier'),
            onPressed: () async {
              if (targetDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sélectionnez une date de destination')),
                );
                return;
              }
              
              Navigator.pop(context);
              
              try {
                final sourceStr = DateFormat('yyyy-MM-dd').format(selectedDate);
                final targetStr = DateFormat('yyyy-MM-dd').format(targetDate!);
                await PlanningService.copyPlanning(widget.childId, sourceStr, targetStr);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Planning copié !'), backgroundColor: Colors.green),
                );
                
                setState(() {
                  selectedDate = targetDate!;
                  _initializeTimeline();
                  _loadPlanning();
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class TimelineSlot {
  final String time;
  Pictogram? pictogram;

  TimelineSlot({required this.time, this.pictogram});
}

