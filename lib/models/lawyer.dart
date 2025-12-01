import 'package:cloud_firestore/cloud_firestore.dart';

class Lawyer {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final List<String> specialties;
  final String licenseNumber;
  final String description;
  final double rating;
  final int consultationsCount;
  final double hourlyRate;
  final bool isAvailable;
  final String? photoUrl;
  final DateTime createdAt;

  Lawyer({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialties,
    required this.licenseNumber,
    required this.description,
    this.rating = 0.0,
    this.consultationsCount = 0,
    required this.hourlyRate,
    this.isAvailable = true,
    this.photoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'specialties': specialties,
      'licenseNumber': licenseNumber,
      'description': description,
      'rating': rating,
      'consultationsCount': consultationsCount,
      'hourlyRate': hourlyRate,
      'isAvailable': isAvailable,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Lawyer.fromMap(Map<String, dynamic> map, String id) {
    return Lawyer(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialties: List<String>.from(map['specialties'] ?? []),
      licenseNumber: map['licenseNumber'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      consultationsCount: map['consultationsCount'] ?? 0,
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      isAvailable: map['isAvailable'] ?? true,
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Lawyer copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    List<String>? specialties,
    String? licenseNumber,
    String? description,
    double? rating,
    int? consultationsCount,
    double? hourlyRate,
    bool? isAvailable,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return Lawyer(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialties: specialties ?? this.specialties,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      consultationsCount: consultationsCount ?? this.consultationsCount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isAvailable: isAvailable ?? this.isAvailable,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
