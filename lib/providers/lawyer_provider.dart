import 'package:flutter/material.dart';
import '../models/lawyer.dart';
import '../models/specialty.dart';
import '../services/firestore_service.dart';

class LawyerProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Lawyer> _lawyers = [];
  List<Specialty> _specialties = [];
  Lawyer? _selectedLawyer;
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedSpecialtyId;

  List<Lawyer> get lawyers => _lawyers;
  List<Specialty> get specialties => _specialties;
  Lawyer? get selectedLawyer => _selectedLawyer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedSpecialtyId => _selectedSpecialtyId;

  List<Lawyer> get filteredLawyers {
    if (_selectedSpecialtyId == null) {
      return _lawyers;
    }
    return _lawyers.where((lawyer) => 
      lawyer.specialties.contains(_selectedSpecialtyId)).toList();
  }

  void setSelectedSpecialty(String? specialtyId) {
    _selectedSpecialtyId = specialtyId;
    notifyListeners();
  }

  void loadSpecialties() {
    _firestoreService.getSpecialties().listen((specialties) {
      _specialties = specialties;
      notifyListeners();
    });
  }

  void loadLawyers({String? specialtyId}) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getLawyers(specialtyId: specialtyId).listen(
      (lawyers) {
        _lawyers = lawyers;
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

  Future<void> selectLawyer(String lawyerId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedLawyer = await _firestoreService.getLawyer(lawyerId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createLawyer(Lawyer lawyer) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.createLawyer(lawyer);

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

  Future<bool> updateLawyer(String lawyerId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateLawyer(lawyerId, updates);

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedLawyer() {
    _selectedLawyer = null;
    notifyListeners();
  }
}
