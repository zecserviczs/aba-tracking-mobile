class SubscriptionType {
  final String name;
  final String displayName;
  final double price;
  final int durationDays;
  final int maxObservationsPerMonth;
  final int maxChildren;
  final bool hasAdvancedAnalytics;
  final bool hasPrioritySupport;
  final String description;
  final List<String> features;

  SubscriptionType({
    required this.name,
    required this.displayName,
    required this.price,
    required this.durationDays,
    required this.maxObservationsPerMonth,
    required this.maxChildren,
    required this.hasAdvancedAnalytics,
    required this.hasPrioritySupport,
    required this.description,
    required this.features,
  });

  factory SubscriptionType.fromJson(Map<String, dynamic> json) {
    return SubscriptionType(
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      durationDays: json['durationDays'] ?? 0,
      maxObservationsPerMonth: json['maxObservationsPerMonth'] ?? 0,
      maxChildren: json['maxChildren'] ?? 0,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] ?? false,
      hasPrioritySupport: json['hasPrioritySupport'] ?? false,
      description: json['description'] ?? '',
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'price': price,
      'durationDays': durationDays,
      'maxObservationsPerMonth': maxObservationsPerMonth,
      'maxChildren': maxChildren,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'hasPrioritySupport': hasPrioritySupport,
      'description': description,
      'features': features,
    };
  }

  bool get isUnlimitedObservations => maxObservationsPerMonth == -1;
  bool get isUnlimitedChildren => maxChildren == -1;
  bool get isFree => price == 0.0;
}

class Subscription {
  final int id;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool autoRenew;
  final String? paymentMethod;
  final String? transactionId;

  Subscription({
    required this.id,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.autoRenew,
    this.paymentMethod,
    this.transactionId,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? false,
      autoRenew: json['autoRenew'] ?? false,
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'autoRenew': autoRenew,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isValid => isActive && !isExpired;
  int get daysRemaining => isExpired ? 0 : endDate.difference(DateTime.now()).inDays;
}

class SubscriptionLimits {
  final bool canCreateObservation;
  final bool canAddChild;
  final bool hasAdvancedAnalytics;
  final bool hasPrioritySupport;

  SubscriptionLimits({
    required this.canCreateObservation,
    required this.canAddChild,
    required this.hasAdvancedAnalytics,
    required this.hasPrioritySupport,
  });

  factory SubscriptionLimits.fromJson(Map<String, dynamic> json) {
    return SubscriptionLimits(
      canCreateObservation: json['canCreateObservation'] ?? false,
      canAddChild: json['canAddChild'] ?? false,
      hasAdvancedAnalytics: json['hasAdvancedAnalytics'] ?? false,
      hasPrioritySupport: json['hasPrioritySupport'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'canCreateObservation': canCreateObservation,
      'canAddChild': canAddChild,
      'hasAdvancedAnalytics': hasAdvancedAnalytics,
      'hasPrioritySupport': hasPrioritySupport,
    };
  }
}








