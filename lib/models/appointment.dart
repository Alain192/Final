import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pendiente';
      case AppointmentStatus.confirmed:
        return 'Confirmada';
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String lawyerId;
  final String lawyerName;
  final String specialtyId;
  final String specialtyName;
  final DateTime scheduledDate;
  final int durationMinutes;
  final AppointmentStatus status;
  final double amount;
  final bool isPaid;
  final String? notes;
  final String? meetingLink;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.lawyerId,
    required this.lawyerName,
    required this.specialtyId,
    required this.specialtyName,
    required this.scheduledDate,
    this.durationMinutes = 60,
    required this.status,
    required this.amount,
    this.isPaid = false,
    this.notes,
    this.meetingLink,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'specialtyId': specialtyId,
      'specialtyName': specialtyName,
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'durationMinutes': durationMinutes,
      'status': status.name,
      'amount': amount,
      'isPaid': isPaid,
      'notes': notes,
      'meetingLink': meetingLink,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map, String id) {
    return Appointment(
      id: id,
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      lawyerId: map['lawyerId'] ?? '',
      lawyerName: map['lawyerName'] ?? '',
      specialtyId: map['specialtyId'] ?? '',
      specialtyName: map['specialtyName'] ?? '',
      scheduledDate: (map['scheduledDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      durationMinutes: map['durationMinutes'] ?? 60,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      amount: (map['amount'] ?? 0.0).toDouble(),
      isPaid: map['isPaid'] ?? false,
      notes: map['notes'],
      meetingLink: map['meetingLink'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Appointment copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? lawyerId,
    String? lawyerName,
    String? specialtyId,
    String? specialtyName,
    DateTime? scheduledDate,
    int? durationMinutes,
    AppointmentStatus? status,
    double? amount,
    bool? isPaid,
    String? notes,
    String? meetingLink,
    DateTime? createdAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      specialtyId: specialtyId ?? this.specialtyId,
      specialtyName: specialtyName ?? this.specialtyName,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      meetingLink: meetingLink ?? this.meetingLink,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
