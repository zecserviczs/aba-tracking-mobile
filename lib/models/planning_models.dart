class Pictogram {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int duration;

  Pictogram({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'duration': duration,
    };
  }

  factory Pictogram.fromJson(Map<String, dynamic> json) {
    return Pictogram(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      duration: json['duration'],
    );
  }
}

class PlanningActivity {
  final int? id;
  final String time;
  final String activityName;
  final String icon;
  final String color;
  final int duration;
  final int orderIndex;

  PlanningActivity({
    this.id,
    required this.time,
    required this.activityName,
    required this.icon,
    required this.color,
    required this.duration,
    required this.orderIndex,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'time': time,
      'activityName': activityName,
      'icon': icon,
      'color': color,
      'duration': duration,
      'orderIndex': orderIndex,
    };
  }

  factory PlanningActivity.fromJson(Map<String, dynamic> json) {
    return PlanningActivity(
      id: json['id'],
      time: json['time'],
      activityName: json['activityName'],
      icon: json['icon'],
      color: json['color'],
      duration: json['duration'],
      orderIndex: json['orderIndex'],
    );
  }
}

class DailyPlanning {
  final int? id;
  final int childId;
  final String date;
  final List<PlanningActivity> activities;
  final String? notes;
  final bool isTemplate;
  final String? templateName;

  DailyPlanning({
    this.id,
    required this.childId,
    required this.date,
    required this.activities,
    this.notes,
    this.isTemplate = false,
    this.templateName,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'childId': childId,
      'date': date,
      'activities': activities.map((a) => a.toJson()).toList(),
      if (notes != null) 'notes': notes,
      'isTemplate': isTemplate,
      if (templateName != null) 'templateName': templateName,
    };
  }

  factory DailyPlanning.fromJson(Map<String, dynamic> json) {
    return DailyPlanning(
      id: json['id'],
      childId: json['childId'],
      date: json['date'],
      activities: (json['activities'] as List?)
              ?.map((a) => PlanningActivity.fromJson(a))
              .toList() ??
          [],
      notes: json['notes'],
      isTemplate: json['isTemplate'] ?? false,
      templateName: json['templateName'],
    );
  }
}

class DiscomfortItem {
  final int? id;
  final String title;
  final String description;
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String category;
  final List<String> triggers;
  final DateTime? lastOccurrence;
  final int frequency;

  DiscomfortItem({
    this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
    required this.triggers,
    this.lastOccurrence,
    required this.frequency,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'severity': severity,
      'category': category,
      'triggers': triggers,
      if (lastOccurrence != null) 'lastOccurrence': lastOccurrence!.toIso8601String(),
      'frequency': frequency,
    };
  }

  factory DiscomfortItem.fromJson(Map<String, dynamic> json) {
    return DiscomfortItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      severity: json['severity'],
      category: json['category'],
      triggers: List<String>.from(json['triggers'] ?? []),
      lastOccurrence: json['lastOccurrence'] != null
          ? DateTime.parse(json['lastOccurrence'])
          : null,
      frequency: json['frequency'],
    );
  }
}






