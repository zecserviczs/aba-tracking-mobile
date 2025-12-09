class Child {
  final int id;
  final String name;
  final int age;
  final String? email;
  final List<ABAObservation>? observations;
  final List<String>? authorizedProfessionalEmails;

  Child({
    required this.id,
    required this.name,
    required this.age,
    this.email,
    this.observations,
    this.authorizedProfessionalEmails,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      email: json['email'],
      observations: json['observations'] != null
          ? (json['observations'] as List)
              .map((obs) => ABAObservation.fromJson(obs))
              .toList()
          : null,
      authorizedProfessionalEmails: json['authorizedProfessionalEmails'] != null
          ? List<String>.from(json['authorizedProfessionalEmails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'observations': observations?.map((obs) => obs.toJson()).toList(),
      'authorizedProfessionalEmails': authorizedProfessionalEmails,
    };
  }

  String get ageCategory {
    if (age < 5) return 'Tout-petit';
    if (age >= 5 && age <= 12) return 'Enfant';
    return 'Adolescent';
  }
}

class ABAObservation {
  final int id;
  final String behaviorType;
  final String severity;
  final String antecedents;
  final String observer;
  final DateTime timestamp;
  final int childId;

  ABAObservation({
    required this.id,
    required this.behaviorType,
    required this.severity,
    required this.antecedents,
    required this.observer,
    required this.timestamp,
    required this.childId,
  });

  factory ABAObservation.fromJson(Map<String, dynamic> json) {
    return ABAObservation(
      id: json['id'] ?? 0,
      behaviorType: json['behaviorType'] ?? '',
      severity: json['severity'] ?? '',
      antecedents: json['antecedents'] ?? '',
      observer: json['observer'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      childId: json['childId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'behaviorType': behaviorType,
      'severity': severity,
      'antecedents': antecedents,
      'observer': observer,
      'timestamp': timestamp.toIso8601String(),
      'childId': childId,
    };
  }
}









