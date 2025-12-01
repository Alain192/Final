import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../models/lawyer.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de usuario autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro
  Future<AppUser?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
    List<String>? specialties,
    String? licenseNumber,
    String? description,
    double? hourlyRate,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Crear documento de usuario en Firestore
        AppUser appUser = AppUser(
          id: user.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
        
        // Actualizar nombre de perfil
        await user.updateDisplayName(name);

        // Si es abogado, crear perfil de abogado
        if (role == UserRole.lawyer && specialties != null && licenseNumber != null) {
          Lawyer lawyer = Lawyer(
            id: user.uid,
            userId: user.uid,
            name: name,
            email: email,
            phone: phone,
            specialties: specialties,
            licenseNumber: licenseNumber,
            description: description ?? 'Abogado profesional',
            rating: 5.0,
            consultationsCount: 0,
            hourlyRate: hourlyRate ?? 0.0,
            isAvailable: true,
            createdAt: DateTime.now(),
          );

          await _firestore.collection('lawyers').doc(user.uid).set(lawyer.toMap());
        }

        return appUser;
      }
      return null;
    } catch (e) {
      print('Error en signUp: $e');
      rethrow;
    }
  }

  // Login
  Future<AppUser?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        return await getUserData(user.uid);
      }
      return null;
    } catch (e) {
      print('Error en signIn: $e');
      rethrow;
    }
  }

  // Obtener datos del usuario desde Firestore
  Future<AppUser?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error en getUserData: $e');
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error en signOut: $e');
      rethrow;
    }
  }

  // Actualizar perfil
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore.collection('users').doc(uid).update(updates);

      if (name != null && currentUser != null) {
        await currentUser!.updateDisplayName(name);
      }
    } catch (e) {
      print('Error en updateProfile: $e');
      rethrow;
    }
  }

  // Cambiar contraseña
  Future<void> changePassword(String newPassword) async {
    try {
      await currentUser?.updatePassword(newPassword);
    } catch (e) {
      print('Error en changePassword: $e');
      rethrow;
    }
  }

  // Restablecer contraseña
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error en resetPassword: $e');
      rethrow;
    }
  }
}
