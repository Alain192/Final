import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_role.dart';

class AppUser {
  final String id;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'photoUrl': photoUrl,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'client'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      photoUrl: map['photoUrl'],
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    String? photoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
