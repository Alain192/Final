import 'package:cloud_firestore/cloud_firestore.dart';

enum CaseStatus {
  open,
  inProgress,
  closed,
  archived;

  String get displayName {
    switch (this) {
      case CaseStatus.open:
        return 'Abierto';
      case CaseStatus.inProgress:
        return 'En Progreso';
      case CaseStatus.closed:
        return 'Cerrado';
      case CaseStatus.archived:
        return 'Archivado';
    }
  }
}

class LegalCase {
  final String id;
  final String clientId;
  final String clientName;
  final String lawyerId;
  final String lawyerName;
  final String specialtyId;
  final String specialtyName;
  final String title;
  final String description;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime? closedAt;
  final List<String> documentIds;
  final List<String> noteIds;

  LegalCase({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.lawyerId,
    required this.lawyerName,
    required this.specialtyId,
    required this.specialtyName,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.closedAt,
    this.documentIds = const [],
    this.noteIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'title': title,
      'description': description,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      'documentIds': documentIds,
      'noteIds': noteIds,
    };
  }

  factory LegalCase.fromMap(Map<String, dynamic> map, String id) {
    return LegalCase(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      lawyerId: map['lawyerId'] ?? '',
      lawyerName: map['lawyerName'] ?? '',
      specialtyId: map['specialtyId'] ?? '',
      specialtyName: map['specialtyName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      status: CaseStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => CaseStatus.open,
      ),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      closedAt: (map['closedAt'] as Timestamp?)?.toDate(),
      documentIds: List<String>.from(map['documentIds'] ?? []),
      noteIds: List<String>.from(map['noteIds'] ?? []),
    );
  }

  LegalCase copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? lawyerId,
    String? lawyerName,
    String? specialtyId,
    String? specialtyName,
    String? title,
    String? description,
    CaseStatus? status,
    DateTime? createdAt,
    DateTime? closedAt,
    List<String>? documentIds,
    List<String>? noteIds,
  }) {
    return LegalCase(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      specialtyId: specialtyId ?? this.specialtyId,
      specialtyName: specialtyName ?? this.specialtyName,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      documentIds: documentIds ?? this.documentIds,
      noteIds: noteIds ?? this.noteIds,
    );
  }
}
