import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lawyer.dart';
import '../models/appointment.dart';
import '../models/legal_case.dart';
import '../models/document.dart';
import '../models/case_note.dart';
import '../models/invoice.dart';
import '../models/specialty.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== LAWYERS ==========
  Future<void> createLawyer(Lawyer lawyer) async {
    try {
      await _firestore.collection('lawyers').doc(lawyer.id).set(lawyer.toMap());
    } catch (e) {
      print('Error creating lawyer: $e');
      rethrow;
    }
  }

  Future<Lawyer?> getLawyer(String lawyerId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('lawyers').doc(lawyerId).get();
      if (doc.exists) {
        return Lawyer.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting lawyer: $e');
      return null;
    }
  }

  Stream<List<Lawyer>> getLawyers({String? specialtyId}) {
    Query query = _firestore.collection('lawyers').where('isAvailable', isEqualTo: true);
    
    if (specialtyId != null) {
      query = query.where('specialties', arrayContains: specialtyId);
    }

    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Lawyer.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  Future<void> updateLawyer(String lawyerId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('lawyers').doc(lawyerId).update(updates);
    } catch (e) {
      print('Error updating lawyer: $e');
      rethrow;
    }
  }

  // ========== APPOINTMENTS ==========
  Future<String> createAppointment(Appointment appointment) async {
    try {
      DocumentReference ref = await _firestore.collection('appointments').add(appointment.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (doc.exists) {
        return Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting appointment: $e');
      return null;
    }
  }

  Stream<List<Appointment>> getAppointmentsByClient(String clientId) {
    return _firestore
        .collection('appointments')
        .where('clientId', isEqualTo: clientId)
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Appointment>> getAppointmentsByLawyer(String lawyerId) {
    return _firestore
        .collection('appointments')
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Appointment>> getAllAppointments() {
    return _firestore
        .collection('appointments')
        .orderBy('scheduledDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Appointment.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateAppointment(String appointmentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update(updates);
    } catch (e) {
      print('Error updating appointment: $e');
      rethrow;
    }
  }

  // ========== CASES ==========
  Future<String> createCase(LegalCase legalCase) async {
    try {
      DocumentReference ref = await _firestore.collection('cases').add(legalCase.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating case: $e');
      rethrow;
    }
  }

  Future<LegalCase?> getCase(String caseId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('cases').doc(caseId).get();
      if (doc.exists) {
        return LegalCase.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting case: $e');
      return null;
    }
  }

  Stream<List<LegalCase>> getCasesByClient(String clientId) {
    return _firestore
        .collection('cases')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalCase.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<LegalCase>> getCasesByLawyer(String lawyerId) {
    return _firestore
        .collection('cases')
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalCase.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<LegalCase>> getCasesByClientAndLawyer(String clientId, String lawyerId) async {
    try {
      final snapshot = await _firestore
          .collection('cases')
          .where('clientId', isEqualTo: clientId)
          .where('lawyerId', isEqualTo: lawyerId)
          .get();
      
      return snapshot.docs
          .map((doc) => LegalCase.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting cases by client and lawyer: $e');
      return [];
    }
  }

  Stream<List<LegalCase>> getAllCases() {
    return _firestore
        .collection('cases')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LegalCase.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateCase(String caseId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('cases').doc(caseId).update(updates);
    } catch (e) {
      print('Error updating case: $e');
      rethrow;
    }
  }

  // ========== DOCUMENTS ==========
  Future<String> createDocument(Document document) async {
    try {
      DocumentReference ref = await _firestore.collection('documents').add(document.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  Future<Document?> getDocument(String documentId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('documents').doc(documentId).get();
      if (doc.exists) {
        return Document.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  Stream<List<Document>> getDocumentsByCase(String caseId) {
    return _firestore
        .collection('documents')
        .where('caseId', isEqualTo: caseId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Document.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Document>> getDocumentsSharedWith(String userId) {
    return _firestore
        .collection('documents')
        .where('sharedWith', arrayContains: userId)
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Document.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateDocument(String documentId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('documents').doc(documentId).update(updates);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection('documents').doc(documentId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  // ========== CASE NOTES ==========
  Future<String> createCaseNote(CaseNote note) async {
    try {
      DocumentReference ref = await _firestore.collection('caseNotes').add(note.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating case note: $e');
      rethrow;
    }
  }

  Stream<List<CaseNote>> getNotesByCase(String caseId) {
    return _firestore
        .collection('caseNotes')
        .where('caseId', isEqualTo: caseId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseNote.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<CaseNote>> getNotesByAppointment(String appointmentId) {
    return _firestore
        .collection('caseNotes')
        .where('appointmentId', isEqualTo: appointmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseNote.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateCaseNote(String noteId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('caseNotes').doc(noteId).update(updates);
    } catch (e) {
      print('Error updating case note: $e');
      rethrow;
    }
  }

  // ========== INVOICES ==========
  Future<String> createInvoice(Invoice invoice) async {
    try {
      DocumentReference ref = await _firestore.collection('invoices').add(invoice.toMap());
      return ref.id;
    } catch (e) {
      print('Error creating invoice: $e');
      rethrow;
    }
  }

  Future<Invoice?> getInvoice(String invoiceId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('invoices').doc(invoiceId).get();
      if (doc.exists) {
        return Invoice.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting invoice: $e');
      return null;
    }
  }

  Stream<List<Invoice>> getInvoicesByClient(String clientId) {
    return _firestore
        .collection('invoices')
        .where('clientId', isEqualTo: clientId)
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invoice.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Invoice>> getInvoicesByLawyer(String lawyerId) {
    return _firestore
        .collection('invoices')
        .where('lawyerId', isEqualTo: lawyerId)
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invoice.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<Invoice>> getAllInvoices() {
    return _firestore
        .collection('invoices')
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Invoice.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateInvoice(String invoiceId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update(updates);
    } catch (e) {
      print('Error updating invoice: $e');
      rethrow;
    }
  }

  // ========== SPECIALTIES ==========
  Future<void> initializeSpecialties() async {
    try {
      final specialties = Specialty.getDefaultSpecialties();
      for (var specialty in specialties) {
        await _firestore.collection('specialties').doc(specialty.id).set(specialty.toMap());
      }
    } catch (e) {
      print('Error initializing specialties: $e');
    }
  }

  Stream<List<Specialty>> getSpecialties() {
    return _firestore
        .collection('specialties')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Specialty.fromMap(doc.data(), doc.id))
            .toList());
  }

  // ========== STATISTICS ==========
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final lawyersCount = await _firestore.collection('lawyers').count().get();
      final casesCount = await _firestore.collection('cases').count().get();
      final appointmentsCount = await _firestore.collection('appointments').count().get();
      
      return {
        'lawyersCount': lawyersCount.count ?? 0,
        'casesCount': casesCount.count ?? 0,
        'appointmentsCount': appointmentsCount.count ?? 0,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }
}
