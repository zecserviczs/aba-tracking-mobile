// Modèles pour les vérifications de stock programmées

import 'package:flutter/material.dart';

class StockChecklist {
  final int? id;
  final String name;
  final String description;
  final String scheduledTime; // Format HH:mm
  final String frequency; // DAILY, WEEKLY, MONTHLY, CUSTOM
  final String? dayOfWeek;
  final int? dayOfMonth;
  final bool isActive;
  final bool isCompleted;
  final DateTime? lastCompleted;
  final DateTime? nextScheduled;
  final ChecklistType type;
  final int childId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockChecklist({
    this.id,
    required this.name,
    required this.description,
    required this.scheduledTime,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.isActive,
    required this.isCompleted,
    this.lastCompleted,
    this.nextScheduled,
    required this.type,
    required this.childId,
    this.createdAt,
    this.updatedAt,
  });

  factory StockChecklist.fromJson(Map<String, dynamic> json) {
    return StockChecklist(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      scheduledTime: json['scheduledTime'] ?? '09:00',
      frequency: json['frequency'] ?? 'WEEKLY',
      dayOfWeek: json['dayOfWeek'],
      dayOfMonth: json['dayOfMonth'],
      isActive: json['isActive'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
      lastCompleted: json['lastCompleted'] != null ? DateTime.parse(json['lastCompleted']) : null,
      nextScheduled: json['nextScheduled'] != null ? DateTime.parse(json['nextScheduled']) : null,
      type: ChecklistType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChecklistType.ROUTINE,
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
      'dayOfMonth': dayOfMonth,
      'isActive': isActive,
      'isCompleted': isCompleted,
      'type': type.name,
      'child': {'id': childId},
    };
  }

  StockChecklist copyWith({
    int? id,
    String? name,
    String? description,
    String? scheduledTime,
    String? frequency,
    String? dayOfWeek,
    int? dayOfMonth,
    bool? isActive,
    bool? isCompleted,
    DateTime? lastCompleted,
    DateTime? nextScheduled,
    ChecklistType? type,
    int? childId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockChecklist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      frequency: frequency ?? this.frequency,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      lastCompleted: lastCompleted ?? this.lastCompleted,
      nextScheduled: nextScheduled ?? this.nextScheduled,
      type: type ?? this.type,
      childId: childId ?? this.childId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ChecklistType {
  ROUTINE('Vérification de routine'),
  EMERGENCY('Vérification d\'urgence'),
  REGULAR('Vérification régulière'),
  SEASONAL('Vérification saisonnière');

  const ChecklistType(this.displayName);
  final String displayName;

  IconData get icon {
    switch (this) {
      case ChecklistType.ROUTINE:
        return Icons.schedule;
      case ChecklistType.EMERGENCY:
        return Icons.warning;
      case ChecklistType.REGULAR:
        return Icons.checklist;
      case ChecklistType.SEASONAL:
        return Icons.calendar_today;
    }
  }

  Color get color {
    switch (this) {
      case ChecklistType.ROUTINE:
        return Colors.blue;
      case ChecklistType.EMERGENCY:
        return Colors.red;
      case ChecklistType.REGULAR:
        return Colors.green;
      case ChecklistType.SEASONAL:
        return Colors.orange;
    }
  }
}

class StockCheckItem {
  final int? id;
  final String name;
  final String description;
  final int currentStock;
  final int minimumStock;
  final int recommendedStock;
  final String unit;
  final bool isChecked;
  final bool needsRestock;
  final String? notes;
  final StockStatus status;
  final int checklistId;
  final int? comfortItemId;
  final DateTime? lastChecked;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  StockCheckItem({
    this.id,
    required this.name,
    required this.description,
    required this.currentStock,
    required this.minimumStock,
    required this.recommendedStock,
    required this.unit,
    required this.isChecked,
    required this.needsRestock,
    this.notes,
    required this.status,
    required this.checklistId,
    this.comfortItemId,
    this.lastChecked,
    this.createdAt,
    this.updatedAt,
  });

  factory StockCheckItem.fromJson(Map<String, dynamic> json) {
    return StockCheckItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      currentStock: json['currentStock'] ?? 0,
      minimumStock: json['minimumStock'] ?? 1,
      recommendedStock: json['recommendedStock'] ?? 3,
      unit: json['unit'] ?? 'pièce',
      isChecked: json['isChecked'] ?? false,
      needsRestock: json['needsRestock'] ?? false,
      notes: json['notes'],
      status: StockStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StockStatus.UNKNOWN,
      ),
      checklistId: json['checklist']?['id'] ?? json['checklistId'] ?? 0,
      comfortItemId: json['comfortItem']?['id'],
      lastChecked: json['lastChecked'] != null ? DateTime.parse(json['lastChecked']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'recommendedStock': recommendedStock,
      'unit': unit,
      'isChecked': isChecked,
      'needsRestock': needsRestock,
      'notes': notes,
      'status': status.name,
      'checklist': {'id': checklistId},
      'comfortItem': comfortItemId != null ? {'id': comfortItemId} : null,
    };
  }

  StockCheckItem copyWith({
    int? id,
    String? name,
    String? description,
    int? currentStock,
    int? minimumStock,
    int? recommendedStock,
    String? unit,
    bool? isChecked,
    bool? needsRestock,
    String? notes,
    StockStatus? status,
    int? checklistId,
    int? comfortItemId,
    DateTime? lastChecked,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StockCheckItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      recommendedStock: recommendedStock ?? this.recommendedStock,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      needsRestock: needsRestock ?? this.needsRestock,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      checklistId: checklistId ?? this.checklistId,
      comfortItemId: comfortItemId ?? this.comfortItemId,
      lastChecked: lastChecked ?? this.lastChecked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get stockPercentage {
    if (recommendedStock == 0) return 0.0;
    return (currentStock * 100.0 / recommendedStock).clamp(0.0, 100.0);
  }

  bool get isCritical {
    return status == StockStatus.OUT_OF_STOCK || status == StockStatus.LOW_STOCK;
  }
}

enum StockStatus {
  IN_STOCK('En stock'),
  LOW_STOCK('Stock faible'),
  OUT_OF_STOCK('Rupture de stock'),
  UNKNOWN('Non vérifié');

  const StockStatus(this.displayName);
  final String displayName;

  Color get color {
    switch (this) {
      case StockStatus.IN_STOCK:
        return Colors.green;
      case StockStatus.LOW_STOCK:
        return Colors.orange;
      case StockStatus.OUT_OF_STOCK:
        return Colors.red;
      case StockStatus.UNKNOWN:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case StockStatus.IN_STOCK:
        return Icons.check_circle;
      case StockStatus.LOW_STOCK:
        return Icons.warning;
      case StockStatus.OUT_OF_STOCK:
        return Icons.cancel;
      case StockStatus.UNKNOWN:
        return Icons.help_outline;
    }
  }
}

class StockStats {
  final int totalChecklists;
  final int overdueChecklists;
  final int totalItems;
  final int checkedItems;
  final int itemsNeedingRestock;

  StockStats({
    required this.totalChecklists,
    required this.overdueChecklists,
    required this.totalItems,
    required this.checkedItems,
    required this.itemsNeedingRestock,
  });

  factory StockStats.fromJson(Map<String, dynamic> json) {
    return StockStats(
      totalChecklists: json['totalChecklists'] ?? 0,
      overdueChecklists: json['overdueChecklists'] ?? 0,
      totalItems: json['totalItems'] ?? 0,
      checkedItems: json['checkedItems'] ?? 0,
      itemsNeedingRestock: json['itemsNeedingRestock'] ?? 0,
    );
  }

  double get completionPercentage {
    if (totalItems == 0) return 0.0;
    return (checkedItems * 100.0 / totalItems).clamp(0.0, 100.0);
  }
}







