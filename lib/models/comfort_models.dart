// Modèles pour les routines et éléments de confort
import 'package:flutter/material.dart';

class Routine {
  final int? id;
  final String name;
  final String description;
  final String scheduledTime; // Format HH:mm
  final String frequency; // DAILY, WEEKLY, CUSTOM
  final String? dayOfWeek;
  final bool isActive;
  final int priority; // 1-5
  final RoutineType type;
  final int childId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Routine({
    this.id,
    required this.name,
    required this.description,
    required this.scheduledTime,
    required this.frequency,
    this.dayOfWeek,
    required this.isActive,
    required this.priority,
    required this.type,
    required this.childId,
    this.createdAt,
    this.updatedAt,
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      scheduledTime: json['scheduledTime'] ?? '08:00',
      frequency: json['frequency'] ?? 'DAILY',
      dayOfWeek: json['dayOfWeek'],
      isActive: json['isActive'] ?? true,
      priority: json['priority'] ?? 3,
      type: RoutineType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoutineType.MORNING,
      ),
      childId: json['child']?['id'] ?? json['childId'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'scheduledTime': scheduledTime,
      'frequency': frequency,
      'dayOfWeek': dayOfWeek,
      'isActive': isActive,
      'priority': priority,
      'type': type.name,
      'child': {'id': childId},
    };
  }

  Routine copyWith({
    int? id,
    String? name,
    String? description,
    String? scheduledTime,
    String? frequency,
    String? dayOfWeek,
    bool? isActive,
    int? priority,
    RoutineType? type,
    int? childId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Routine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      type: type ?? this.type,
      childId: childId ?? this.childId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum RoutineType {
  MORNING('Routine matinale'),
  EVENING('Routine du soir'),
  BEDTIME('Routine du coucher'),
  MEAL('Routine repas'),
  ACTIVITY('Routine activité'),
  TRANSITION('Routine de transition'),
  HYGIENE('Routine hygiène'),
  LEARNING('Routine d\'apprentissage');

  const RoutineType(this.displayName);
  final String displayName;
}

class ComfortItem {
  final int? id;
  final String name;
  final String description;
  final String? brand;
  final String? size;
  final String? color;
  final String? scent;
  final ComfortItemType type;
  final ComfortLevel comfortLevel;
  final String? location;
  final String? usage;
  final bool isAvailable;
  final bool needsReplacement;
  final String? notes;
  final int childId;
  final int? categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastUsed;

  ComfortItem({
    this.id,
    required this.name,
    required this.description,
    this.brand,
    this.size,
    this.color,
    this.scent,
    required this.type,
    required this.comfortLevel,
    this.location,
    this.usage,
    required this.isAvailable,
    required this.needsReplacement,
    this.notes,
    required this.childId,
    this.categoryId,
    this.createdAt,
    this.updatedAt,
    this.lastUsed,
  });

  factory ComfortItem.fromJson(Map<String, dynamic> json) {
    return ComfortItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      brand: json['brand'],
      size: json['size'],
      color: json['color'],
      scent: json['scent'],
      type: ComfortItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ComfortItemType.OTHER,
      ),
      comfortLevel: ComfortLevel.values.firstWhere(
        (e) => e.name == json['comfortLevel'],
        orElse: () => ComfortLevel.MEDIUM,
      ),
      location: json['location'],
      usage: json['usage'],
      isAvailable: json['isAvailable'] ?? true,
      needsReplacement: json['needsReplacement'] ?? false,
      notes: json['notes'],
      childId: json['child']?['id'] ?? json['childId'] ?? 0,
      categoryId: json['category']?['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'brand': brand,
      'size': size,
      'color': color,
      'scent': scent,
      'type': type.name,
      'comfortLevel': comfortLevel.name,
      'location': location,
      'usage': usage,
      'isAvailable': isAvailable,
      'needsReplacement': needsReplacement,
      'notes': notes,
      'child': {'id': childId},
      'category': categoryId != null ? {'id': categoryId} : null,
    };
  }

  ComfortItem copyWith({
    int? id,
    String? name,
    String? description,
    String? brand,
    String? size,
    String? color,
    String? scent,
    ComfortItemType? type,
    ComfortLevel? comfortLevel,
    String? location,
    String? usage,
    bool? isAvailable,
    bool? needsReplacement,
    String? notes,
    int? childId,
    int? categoryId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastUsed,
  }) {
    return ComfortItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      color: color ?? this.color,
      scent: scent ?? this.scent,
      type: type ?? this.type,
      comfortLevel: comfortLevel ?? this.comfortLevel,
      location: location ?? this.location,
      usage: usage ?? this.usage,
      isAvailable: isAvailable ?? this.isAvailable,
      needsReplacement: needsReplacement ?? this.needsReplacement,
      notes: notes ?? this.notes,
      childId: childId ?? this.childId,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}

enum ComfortItemType {
  FOOD('Nourriture'),
  BEVERAGE('Boisson'),
  BATH_PRODUCT('Produit de bain'),
  PERFUME('Parfum'),
  CLOTHING('Vêtement'),
  TOY('Jouet'),
  BOOK('Livre'),
  BLANKET('Couverture'),
  PILLOW('Oreiller'),
  FURNITURE('Meuble'),
  DECORATION('Décoration'),
  LIGHTING('Éclairage'),
  SOUND('Son'),
  TEXTURE('Texture'),
  SMELL('Odeur'),
  ROUTINE_OBJECT('Objet de routine'),
  TRANSITION_OBJECT('Objet de transition'),
  SENSORY_TOOL('Outil sensoriel'),
  OTHER('Autre');

  const ComfortItemType(this.displayName);
  final String displayName;
}

enum ComfortLevel {
  CRITICAL('Critique - Indispensable'),
  HIGH('Élevé - Très important'),
  MEDIUM('Moyen - Important'),
  LOW('Faible - Optionnel'),
  UNKNOWN('Inconnu - À évaluer');

  const ComfortLevel(this.displayName);
  final String displayName;

  Color get color {
    switch (this) {
      case ComfortLevel.CRITICAL:
        return Colors.red;
      case ComfortLevel.HIGH:
        return Colors.orange;
      case ComfortLevel.MEDIUM:
        return Colors.yellow;
      case ComfortLevel.LOW:
        return Colors.green;
      case ComfortLevel.UNKNOWN:
        return Colors.grey;
    }
  }
}

class ComfortCategory {
  final int? id;
  final String name;
  final String description;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ComfortCategory({
    this.id,
    required this.name,
    required this.description,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ComfortCategory.fromJson(Map<String, dynamic> json) {
    return ComfortCategory(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'],
      color: json['color'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }
}

class ComfortStats {
  final int totalRoutines;
  final int totalComfortItems;
  final int criticalItems;
  final int itemsNeedingReplacement;

  ComfortStats({
    required this.totalRoutines,
    required this.totalComfortItems,
    required this.criticalItems,
    required this.itemsNeedingReplacement,
  });

  factory ComfortStats.fromJson(Map<String, dynamic> json) {
    return ComfortStats(
      totalRoutines: json['totalRoutines'] ?? 0,
      totalComfortItems: json['totalComfortItems'] ?? 0,
      criticalItems: json['criticalItems'] ?? 0,
      itemsNeedingReplacement: json['itemsNeedingReplacement'] ?? 0,
    );
  }
}
