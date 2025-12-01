import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceStatus {
  pending,
  paid,
  cancelled;

  String get displayName {
    switch (this) {
      case InvoiceStatus.pending:
        return 'Pendiente';
      case InvoiceStatus.paid:
        return 'Pagada';
      case InvoiceStatus.cancelled:
        return 'Cancelada';
    }
  }
}

class Invoice {
  final String id;
  final String appointmentId;
  final String clientId;
  final String clientName;
  final String lawyerId;
  final String lawyerName;
  final double amount;
  final double tax;
  final double total;
  final InvoiceStatus status;
  final String description;
  final DateTime issueDate;
  final DateTime? paidDate;
  final String? paymentMethod;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.appointmentId,
    required this.clientId,
    required this.clientName,
    required this.lawyerId,
    required this.lawyerName,
    required this.amount,
    this.tax = 0.0,
    required this.total,
    required this.status,
    required this.description,
    required this.issueDate,
    this.paidDate,
    this.paymentMethod,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'clientId': clientId,
      'clientName': clientName,
      'lawyerId': lawyerId,
      'lawyerName': lawyerName,
      'amount': amount,
      'tax': tax,
      'total': total,
      'status': status.name,
      'description': description,
      'issueDate': Timestamp.fromDate(issueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'paymentMethod': paymentMethod,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, String id) {
    return Invoice(
      id: id,
      appointmentId: map['appointmentId'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      lawyerId: map['lawyerId'] ?? '',
      lawyerName: map['lawyerName'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      description: map['description'] ?? '',
      issueDate: (map['issueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paidDate: (map['paidDate'] as Timestamp?)?.toDate(),
      paymentMethod: map['paymentMethod'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Invoice copyWith({
    String? id,
    String? appointmentId,
    String? clientId,
    String? clientName,
    String? lawyerId,
    String? lawyerName,
    double? amount,
    double? tax,
    double? total,
    InvoiceStatus? status,
    String? description,
    DateTime? issueDate,
    DateTime? paidDate,
    String? paymentMethod,
    DateTime? createdAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      lawyerId: lawyerId ?? this.lawyerId,
      lawyerName: lawyerName ?? this.lawyerName,
      amount: amount ?? this.amount,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      description: description ?? this.description,
      issueDate: issueDate ?? this.issueDate,
      paidDate: paidDate ?? this.paidDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
