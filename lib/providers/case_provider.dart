import 'package:flutter/material.dart';
import '../models/legal_case.dart';
import '../services/firestore_service.dart';

class CaseProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<LegalCase> _cases = [];
  LegalCase? _selectedCase;
  bool _isLoading = false;
  String? _errorMessage;

  List<LegalCase> get cases => _cases;
  LegalCase? get selectedCase => _selectedCase;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<LegalCase> get openCases {
    return _cases.where((c) => 
      c.status == CaseStatus.open || c.status == CaseStatus.inProgress
    ).toList();
  }

  List<LegalCase> get closedCases {
    return _cases.where((c) => 
      c.status == CaseStatus.closed || c.status == CaseStatus.archived
    ).toList();
  }

  void loadCasesByClient(String clientId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getCasesByClient(clientId).listen(
      (cases) {
        _cases = cases;
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

  void loadCasesByLawyer(String lawyerId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getCasesByLawyer(lawyerId).listen(
      (cases) {
        _cases = cases;
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

  void loadAllCases() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getAllCases().listen(
      (cases) {
        _cases = cases;
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

  Future<String?> createCase(LegalCase legalCase) async {
    try {
      _isLoading = true;
      notifyListeners();

      String caseId = await _firestoreService.createCase(legalCase);

      _isLoading = false;
      notifyListeners();
      return caseId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateCase(String caseId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateCase(caseId, updates);

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

  Future<bool> updateCaseStatus(String caseId, CaseStatus status) async {
    Map<String, dynamic> updates = {'status': status.name};
    
    if (status == CaseStatus.closed) {
      updates['closedAt'] = DateTime.now();
    }

    return await updateCase(caseId, updates);
  }

  Future<void> selectCase(String caseId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedCase = await _firestoreService.getCase(caseId);

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

  void clearSelectedCase() {
    _selectedCase = null;
    notifyListeners();
  }
}
