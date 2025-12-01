import 'package:cloud_firestore/cloud_firestore.dart';

class CaseNote {
  final String id;
  final String caseId;
  final String appointmentId;
  final String authorId;
  final String authorName;
  final String title;
  final String content;
  final String? nextSteps;
  final DateTime createdAt;
  final bool isSharedWithClient;

  CaseNote({
    required this.id,
    required this.caseId,
    required this.appointmentId,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.content,
    this.nextSteps,
    required this.createdAt,
    this.isSharedWithClient = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'caseId': caseId,
      'appointmentId': appointmentId,
      'authorId': authorId,
      'authorName': authorName,
      'title': title,
      'content': content,
      'nextSteps': nextSteps,
      'createdAt': Timestamp.fromDate(createdAt),
      'isSharedWithClient': isSharedWithClient,
    };
  }

  factory CaseNote.fromMap(Map<String, dynamic> map, String id) {
    return CaseNote(
      id: id,
      caseId: map['caseId'] ?? '',
      appointmentId: map['appointmentId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      nextSteps: map['nextSteps'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isSharedWithClient: map['isSharedWithClient'] ?? true,
    );
  }

  CaseNote copyWith({
    String? id,
    String? caseId,
    String? appointmentId,
    String? authorId,
    String? authorName,
    String? title,
    String? content,
    String? nextSteps,
    DateTime? createdAt,
    bool? isSharedWithClient,
  }) {
    return CaseNote(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      appointmentId: appointmentId ?? this.appointmentId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      title: title ?? this.title,
      content: content ?? this.content,
      nextSteps: nextSteps ?? this.nextSteps,
      createdAt: createdAt ?? this.createdAt,
      isSharedWithClient: isSharedWithClient ?? this.isSharedWithClient,
    );
  }
}
