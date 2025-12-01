import 'dart:io';
import 'package:flutter/material.dart';
import '../models/document.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class DocumentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  List<Document> _documents = [];
  Document? _selectedDocument;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  List<Document> get documents => _documents;
  Document? get selectedDocument => _selectedDocument;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  void loadDocumentsByCase(String caseId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getDocumentsByCase(caseId).listen(
      (documents) {
        _documents = documents;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadDocumentsSharedWith(String userId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getDocumentsSharedWith(userId).listen(
      (documents) {
        _documents = documents;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> uploadDocument({
    required File file,
    required String name,
    required String description,
    required DocumentType type,
    required String uploadedBy,
    required String uploaderName,
    String? caseId,
    String? appointmentId,
    List<String> sharedWith = const [],
  }) async {
    try {
      _isUploading = true;
      _uploadProgress = 0.0;
      notifyListeners();

      // Subir archivo a Storage
      final uploadResult = await _storageService.uploadDocument(
        file: file,
        userId: uploadedBy,
        caseId: caseId,
      );

      _uploadProgress = 0.5;
      notifyListeners();

      // Obtener información del archivo
      final fileExtension = file.path.split('.').last;
      final fileSizeBytes = await file.length();

      // Crear documento en Firestore
      final document = Document(
        id: '',
        name: name,
        description: description,
        type: type,
        uploadedBy: uploadedBy,
        uploaderName: uploaderName,
        caseId: caseId,
        appointmentId: appointmentId,
        downloadUrl: uploadResult['downloadUrl']!,
        storagePath: uploadResult['storagePath']!,
        fileSizeBytes: fileSizeBytes,
        fileExtension: fileExtension,
        uploadedAt: DateTime.now(),
        sharedWith: sharedWith,
      );

      await _firestoreService.createDocument(document);

      _uploadProgress = 1.0;
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return false;
    }
  }

  Future<bool> shareDocument(String documentId, String userId) async {
    try {
      final document = await _firestoreService.getDocument(documentId);
      if (document == null) return false;

      List<String> sharedWith = List.from(document.sharedWith);
      if (!sharedWith.contains(userId)) {
        sharedWith.add(userId);
      }

      await _firestoreService.updateDocument(documentId, {
        'sharedWith': sharedWith,
      });

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(String documentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final document = await _firestoreService.getDocument(documentId);
      if (document != null) {
        // Eliminar archivo de Storage
        await _storageService.deleteFile(document.storagePath);
        // Eliminar documento de Firestore
        await _firestoreService.deleteDocument(documentId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> selectDocument(String documentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedDocument = await _firestoreService.getDocument(documentId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedDocument() {
    _selectedDocument = null;
    notifyListeners();
  }
}
