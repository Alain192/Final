import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../models/invoice.dart';
import '../models/legal_case.dart';
import '../services/firestore_service.dart';

class AppointmentProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Appointment> _appointments = [];
  Appointment? _selectedAppointment;
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  Appointment? get selectedAppointment => _selectedAppointment;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments.where((apt) => 
      apt.scheduledDate.isAfter(now) && 
      apt.status != AppointmentStatus.cancelled
    ).toList()..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments.where((apt) => 
      apt.scheduledDate.isBefore(now) || 
      apt.status == AppointmentStatus.completed
    ).toList()..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  void loadAppointmentsByClient(String clientId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getAppointmentsByClient(clientId).listen(
      (appointments) {
        _appointments = appointments;
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

  void loadAppointmentsByLawyer(String lawyerId) {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getAppointmentsByLawyer(lawyerId).listen(
      (appointments) {
        _appointments = appointments;
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

  void loadAllAppointments() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getAllAppointments().listen(
      (appointments) {
        _appointments = appointments;
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

  Future<String?> createAppointment(Appointment appointment) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Crear la cita
      String appointmentId = await _firestoreService.createAppointment(appointment);

      // 2. Verificar si existe un caso entre el cliente y el abogado
      final existingCases = await _firestoreService.getCasesByClientAndLawyer(
        appointment.clientId,
        appointment.lawyerId,
      );

      // 3. Si no existe un caso, crear uno automáticamente
      if (existingCases.isEmpty) {
        final newCase = LegalCase(
          id: '',
          clientId: appointment.clientId,
          clientName: appointment.clientName,
          lawyerId: appointment.lawyerId,
          lawyerName: appointment.lawyerName,
          specialtyId: appointment.specialtyId,
          specialtyName: appointment.specialtyName,
          title: 'Caso de ${appointment.clientName}',
          description: 'Caso creado automáticamente al reservar cita',
          status: CaseStatus.open,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createCase(newCase);
      }

      _isLoading = false;
      notifyListeners();
      return appointmentId;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestoreService.updateAppointment(appointmentId, updates);

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

  Future<bool> confirmAppointment(String appointmentId) async {
    return await updateAppointment(appointmentId, {
      'status': AppointmentStatus.confirmed.name,
    });
  }

  Future<bool> completeAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // 1. Obtener datos de la cita
      final appointment = await _firestoreService.getAppointment(appointmentId);
      if (appointment == null) {
        _errorMessage = 'Cita no encontrada';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Actualizar estado de la cita a completada
      await _firestoreService.updateAppointment(appointmentId, {
        'status': AppointmentStatus.completed.name,
      });

      // 3. Crear factura automáticamente
      final now = DateTime.now();
      final invoice = Invoice(
        id: '',
        appointmentId: appointmentId,
        clientId: appointment.clientId,
        clientName: appointment.clientName,
        lawyerId: appointment.lawyerId,
        lawyerName: appointment.lawyerName,
        amount: appointment.amount,
        tax: appointment.amount * 0.18, // 18% IGV
        total: appointment.amount * 1.18,
        status: InvoiceStatus.paid, // ✅ PAGADA automáticamente
        description: 'Pago por consulta legal - ${appointment.specialtyName}',
        issueDate: now,
        paidDate: now, // ✅ Fecha de pago = ahora
        paymentMethod: 'efectivo', // Método por defecto
        createdAt: now,
      );

      // 4. Guardar factura en Firestore
      await _firestoreService.createInvoice(invoice);

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

  Future<bool> cancelAppointment(String appointmentId) async {
    return await updateAppointment(appointmentId, {
      'status': AppointmentStatus.cancelled.name,
    });
  }

  Future<void> selectAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _selectedAppointment = await _firestoreService.getAppointment(appointmentId);

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

  void clearSelectedAppointment() {
    _selectedAppointment = null;
    notifyListeners();
  }
}
