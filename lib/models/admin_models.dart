class AdminStats {
  final int totalUsers;
  final int totalParents;
  final int totalProfessionals;
  final int totalChildren;
  final int totalObservations;
  final int totalSocialScenarios;
  final int totalKnowledgeBaseEntries;

  AdminStats({
    required this.totalUsers,
    required this.totalParents,
    required this.totalProfessionals,
    required this.totalChildren,
    required this.totalObservations,
    required this.totalSocialScenarios,
    required this.totalKnowledgeBaseEntries,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalParents: json['totalParents'] ?? 0,
      totalProfessionals: json['totalProfessionals'] ?? 0,
      totalChildren: json['totalChildren'] ?? 0,
      totalObservations: json['totalObservations'] ?? 0,
      totalSocialScenarios: json['totalSocialScenarios'] ?? 0,
      totalKnowledgeBaseEntries: json['totalKnowledgeBaseEntries'] ?? 0,
    );
  }
}

class UserManagementRequest {
  final String? email;
  final List<String>? newRoles;
  final bool? isActive;

  UserManagementRequest({
    this.email,
    this.newRoles,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'newRoles': newRoles,
      'isActive': isActive,
    };
  }
}

class KnowledgeBaseEntry {
  final int? id;
  final String title;
  final String content;
  final String? category;
  final String? keywords;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KnowledgeBaseEntry({
    this.id,
    required this.title,
    required this.content,
    this.category,
    this.keywords,
    this.createdAt,
    this.updatedAt,
  });

  factory KnowledgeBaseEntry.fromJson(Map<String, dynamic> json) {
    return KnowledgeBaseEntry(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'],
      keywords: json['keywords'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'keywords': keywords,
    };
  }
}

class AdminUser {
  final int id;
  final String email;
  final String username;
  final List<String> roles;
  final String userType;
  final bool? isActive;

  AdminUser({
    required this.id,
    required this.email,
    required this.username,
    required this.roles,
    required this.userType,
    this.isActive,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? json['userName'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      userType: json['userType'] ?? 'unknown',
      isActive: json['isActive'],
    );
  }
}








