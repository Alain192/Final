import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        _currentUser = await _authService.getUserData(user.uid);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
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
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
        specialties: specialties,
        licenseNumber: licenseNumber,
        description: description,
        hourlyRate: hourlyRate,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      if (_currentUser == null) return false;

      _isLoading = true;
      notifyListeners();

      await _authService.updateProfile(
        uid: _currentUser!.id,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );

      // Actualizar usuario local
      _currentUser = await _authService.getUserData(_currentUser!.id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Este correo ya está registrado';
        case 'invalid-email':
          return 'Correo electrónico inválido';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'too-many-requests':
          return 'Demasiados intentos. Intente más tarde';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error: ${error.toString()}';
  }
}
