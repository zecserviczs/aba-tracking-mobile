class SocialScenarioModel {
  final int id;
  final int? childId;
  final String? childName;
  final String title;
  final String? description;
  final bool shared;
  final bool validatedByParent;
  final bool createdByParent;
  final List<ScenarioStepModel> steps;

  SocialScenarioModel({
    required this.id,
    required this.title,
    this.childId,
    this.childName,
    this.description,
    this.shared = false,
    this.validatedByParent = false,
    this.createdByParent = false,
    this.steps = const [],
  });

  factory SocialScenarioModel.fromJson(Map<String, dynamic> json) {
    return SocialScenarioModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      childId: json['childId'],
      childName: json['childName'],
      shared: json['shared'] ?? false,
      validatedByParent: json['validatedByParent'] ?? false,
      createdByParent: json['createdByParent'] ?? false,
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((step) => ScenarioStepModel.fromJson(step))
          .toList(),
    );
  }
}

class ScenarioStepModel {
  final int? id;
  final String? text;
  final String? description;
  final String? imageUrl;
  final String? icon;
  final String? color;

  ScenarioStepModel({
    this.id,
    this.text,
    this.description,
    this.imageUrl,
    this.icon,
    this.color,
  });

  factory ScenarioStepModel.fromJson(Map<String, dynamic> json) {
    return ScenarioStepModel(
      id: json['id'],
      text: json['text'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class ScenarioGenerationContext {
  final String code;
  final String label;
  final String? description;

  ScenarioGenerationContext({
    required this.code,
    required this.label,
    this.description,
  });

  factory ScenarioGenerationContext.fromJson(Map<String, dynamic> json) {
    return ScenarioGenerationContext(
      code: json['code'] ?? '',
      label: json['label'] ?? '',
      description: json['description'],
    );
  }
}




