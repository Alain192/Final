import 'package:cloud_firestore/cloud_firestore.dart';

enum DocumentType {
  contract,
  evidence,
  report,
  agreement,
  note,
  other;

  String get displayName {
    switch (this) {
      case DocumentType.contract:
        return 'Contrato';
      case DocumentType.evidence:
        return 'Evidencia';
      case DocumentType.report:
        return 'Informe';
      case DocumentType.agreement:
        return 'Acuerdo';
      case DocumentType.note:
        return 'Nota/Acta';
      case DocumentType.other:
        return 'Otro';
    }
  }
}

class Document {
  final String id;
  final String name;
  final String description;
  final DocumentType type;
  final String uploadedBy;
  final String uploaderName;
  final String? caseId;
  final String? appointmentId;
  final String downloadUrl;
  final String storagePath;
  final int fileSizeBytes;
  final String fileExtension;
  final DateTime uploadedAt;
  final List<String> sharedWith;

  Document({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.uploadedBy,
    required this.uploaderName,
    this.caseId,
    this.appointmentId,
    required this.downloadUrl,
    required this.storagePath,
    required this.fileSizeBytes,
    required this.fileExtension,
    required this.uploadedAt,
    this.sharedWith = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'caseId': caseId,
      'appointmentId': appointmentId,
      'downloadUrl': downloadUrl,
      'storagePath': storagePath,
      'fileSizeBytes': fileSizeBytes,
      'fileExtension': fileExtension,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'sharedWith': sharedWith,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map, String id) {
    return Document(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      type: DocumentType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => DocumentType.other,
      ),
      uploadedBy: map['uploadedBy'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      caseId: map['caseId'],
      appointmentId: map['appointmentId'],
      downloadUrl: map['downloadUrl'] ?? '',
      storagePath: map['storagePath'] ?? '',
      fileSizeBytes: map['fileSizeBytes'] ?? 0,
      fileExtension: map['fileExtension'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sharedWith: List<String>.from(map['sharedWith'] ?? []),
    );
  }

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Document copyWith({
    String? id,
    String? name,
    String? description,
    DocumentType? type,
    String? uploadedBy,
    String? uploaderName,
    String? caseId,
    String? appointmentId,
    String? downloadUrl,
    String? storagePath,
    int? fileSizeBytes,
    String? fileExtension,
    DateTime? uploadedAt,
    List<String>? sharedWith,
  }) {
    return Document(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      caseId: caseId ?? this.caseId,
      appointmentId: appointmentId ?? this.appointmentId,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      storagePath: storagePath ?? this.storagePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      fileExtension: fileExtension ?? this.fileExtension,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      sharedWith: sharedWith ?? this.sharedWith,
    );
  }
}
