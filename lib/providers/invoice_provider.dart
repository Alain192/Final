import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/firestore_service.dart';

class InvoiceProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Invoice> _invoices = [];
  Invoice? _selectedInvoice;
  bool _isLoading = false;
  String? _errorMessage;

  List<Invoice> get invoices => _invoices;
  Invoice? get selectedInvoice => _selectedInvoice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Invoice> get pendingInvoices {
    return _invoices.where((inv) => inv.status == InvoiceStatus.pending).toList();
  }

  List<Invoice> get paidInvoices {
    return _invoices.where((inv) => inv.status == InvoiceStatus.paid).toList();
  }

  double get totalRevenue {
    return paidInvoices.fold(0.0, (sum, inv) => sum + inv.total);
  }

  Map<String, double> get revenueByLawyer {
    Map<String, double> revenue = {};
    for (var invoice in paidInvoices) {
      revenue[invoice.lawyerName] = (revenue[invoice.lawyerName] ?? 0.0) + invoice.total;
    }
    return revenue;
  }

  void loadInvoicesByClient(String clientId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getInvoicesByClient(clientId).listen(
      (invoices) {
        _invoices = invoices;
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

  void loadInvoicesByLawyer(String lawyerId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getInvoicesByLawyer(lawyerId).listen(
      (invoices) {
        _invoices = invoices;
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

  void loadAllInvoices() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getAllInvoices().listen(
      (invoices) {
        _invoices = invoices;
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

  Future<String?> createInvoice(Invoice invoice) async {
    try {
      _isLoading = true;
      notifyListeners();

      String invoiceId = await _firestoreService.createInvoice(invoice);

      _isLoading = false;
      notifyListeners();
      return invoiceId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateInvoice(String invoiceId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateInvoice(invoiceId, updates);

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

  Future<bool> markAsPaid(String invoiceId, String paymentMethod) async {
    return await updateInvoice(invoiceId, {
      'status': InvoiceStatus.paid.name,
      'paidDate': DateTime.now(),
      'paymentMethod': paymentMethod,
    });
  }

  Future<bool> cancelInvoice(String invoiceId) async {
    return await updateInvoice(invoiceId, {
      'status': InvoiceStatus.cancelled.name,
    });
  }

  Future<void> selectInvoice(String invoiceId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedInvoice = await _firestoreService.getInvoice(invoiceId);

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

  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }
}
