import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Subir documento
  Future<Map<String, String>> uploadDocument({
    required File file,
    required String userId,
    String? caseId,
  }) async {
    try {
      String fileName = path.basename(file.path);
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String storagePath = 'documents/$userId/${caseId ?? 'general'}/$timestamp-$fileName';

      Reference ref = _storage.ref().child(storagePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return {
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
      };
    } catch (e) {
      print('Error uploading document: $e');
      rethrow;
    }
  }

  // Subir imagen de perfil
  Future<String> uploadProfileImage({
    required File file,
    required String userId,
  }) async {
    try {
      String fileName = path.basename(file.path);
      String storagePath = 'profiles/$userId/$fileName';

      Reference ref = _storage.ref().child(storagePath);
      UploadTask uploadTask = ref.putFile(file);
      
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      rethrow;
    }
  }

  // Eliminar archivo
  Future<void> deleteFile(String storagePath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  // Obtener URL de descarga
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      rethrow;
    }
  }

  // Obtener metadata del archivo
  Future<FullMetadata> getFileMetadata(String storagePath) async {
    try {
      Reference ref = _storage.ref().child(storagePath);
      return await ref.getMetadata();
    } catch (e) {
      print('Error getting file metadata: $e');
      rethrow;
    }
  }
}
