class User {
  final int id;
  final String username;
  final String email;
  final String role;
  final List<String>? roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      roles: json['roles'] != null 
          ? List<String>.from(json['roles']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'roles': roles,
    };
  }

  bool get isParent => role == 'PARENT';
  bool get isProfessional => role == 'PROF';
  bool get isAdmin => role == 'ADMIN';
}



