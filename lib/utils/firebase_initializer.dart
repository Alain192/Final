import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/specialty.dart';

/// Script para inicializar datos de prueba en Firestore
/// Este archivo no debe usarse en producción
/// 
/// Para ejecutar:
/// 1. Importa este archivo en main.dart temporalmente
/// 2. Llama a initializeTestData() después de Firebase.initializeApp()
/// 3. Ejecuta la app una vez
/// 4. Elimina la llamada después de que los datos se creen

class FirebaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa todas las especialidades predefinidas
  static Future<void> initializeSpecialties() async {
    print('🔄 Inicializando especialidades...');
    
    try {
      final specialties = Specialty.getDefaultSpecialties();
      
      for (var specialty in specialties) {
        await _firestore
            .collection('specialties')
            .doc(specialty.id)
            .set(specialty.toMap());
        print('✅ Especialidad creada: ${specialty.name}');
      }
      
      print('✅ Todas las especialidades fueron inicializadas correctamente');
    } catch (e) {
      print('❌ Error al inicializar especialidades: $e');
    }
  }

  /// Crea abogados de prueba (requiere usuarios ya creados)
  static Future<void> createTestLawyers() async {
    print('🔄 Creando abogados de prueba...');
    
    try {
      final testLawyers = [
        {
          'userId': 'REPLACE_WITH_ACTUAL_UID_1',
          'name': 'Dr. Carlos Martínez',
          'email': 'carlos.martinez@abogados.com',
          'phone': '+52 555 1234567',
          'specialties': ['civil', 'comercial'],
          'licenseNumber': 'LAW-2024-001',
          'description': 'Abogado especializado en derecho civil y comercial con 15 años de experiencia. Experto en contratos, derecho empresarial y resolución de conflictos.',
          'rating': 4.8,
          'consultationsCount': 156,
          'hourlyRate': 80.0,
          'isAvailable': true,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'REPLACE_WITH_ACTUAL_UID_2',
          'name': 'Lic. Ana Rodríguez',
          'email': 'ana.rodriguez@abogados.com',
          'phone': '+52 555 2345678',
          'specialties': ['familiar', 'civil'],
          'licenseNumber': 'LAW-2024-002',
          'description': 'Especialista en derecho familiar y de sucesiones. Más de 10 años ayudando a familias en procesos de divorcio, custodia y herencias.',
          'rating': 4.9,
          'consultationsCount': 203,
          'hourlyRate': 75.0,
          'isAvailable': true,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'REPLACE_WITH_ACTUAL_UID_3',
          'name': 'Lic. Roberto Sánchez',
          'email': 'roberto.sanchez@abogados.com',
          'phone': '+52 555 3456789',
          'specialties': ['penal'],
          'licenseNumber': 'LAW-2024-003',
          'description': 'Abogado penalista con amplia experiencia en defensa criminal. Especialista en juicios orales y procedimientos penales.',
          'rating': 4.7,
          'consultationsCount': 89,
          'hourlyRate': 90.0,
          'isAvailable': true,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'REPLACE_WITH_ACTUAL_UID_4',
          'name': 'Lic. María López',
          'email': 'maria.lopez@abogados.com',
          'phone': '+52 555 4567890',
          'specialties': ['laboral', 'civil'],
          'licenseNumber': 'LAW-2024-004',
          'description': 'Experta en derecho laboral y seguridad social. Asesoría en despidos, demandas laborales y contratos de trabajo.',
          'rating': 4.6,
          'consultationsCount': 127,
          'hourlyRate': 70.0,
          'isAvailable': true,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'userId': 'REPLACE_WITH_ACTUAL_UID_5',
          'name': 'Lic. Jorge Hernández',
          'email': 'jorge.hernandez@abogados.com',
          'phone': '+52 555 5678901',
          'specialties': ['tributario', 'comercial'],
          'licenseNumber': 'LAW-2024-005',
          'description': 'Especialista en derecho fiscal y tributario. Asesoría fiscal, planeación tributaria y defensa ante el SAT.',
          'rating': 4.5,
          'consultationsCount': 94,
          'hourlyRate': 85.0,
          'isAvailable': true,
          'photoUrl': null,
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var lawyer in testLawyers) {
        final docRef = await _firestore.collection('lawyers').add(lawyer);
        print('✅ Abogado creado: ${lawyer['name']} (${docRef.id})');
      }
      
      print('✅ Todos los abogados de prueba fueron creados correctamente');
      print('⚠️  IMPORTANTE: Reemplaza los UIDs de usuario con los reales');
    } catch (e) {
      print('❌ Error al crear abogados de prueba: $e');
    }
  }

  /// Inicializa todos los datos de prueba
  static Future<void> initializeAllTestData() async {
    print('🚀 Iniciando inicialización de datos de prueba...');
    print('');
    
    await initializeSpecialties();
    print('');
    
    print('⚠️  Para crear abogados de prueba:');
    print('   1. Primero registra usuarios con rol "lawyer"');
    print('   2. Copia sus UIDs');
    print('   3. Reemplaza los UIDs en createTestLawyers()');
    print('   4. Ejecuta createTestLawyers()');
    print('');
    
    // Descomentar después de actualizar los UIDs
    // await createTestLawyers();
    
    print('🎉 Inicialización completada');
  }
}

/// Widget de utilidad para inicializar datos
class InitializeDataScreen extends StatefulWidget {
  const InitializeDataScreen({super.key});

  @override
  State<InitializeDataScreen> createState() => _InitializeDataScreenState();
}

class _InitializeDataScreenState extends State<InitializeDataScreen> {
  bool _isInitializing = false;
  String _status = '';

  Future<void> _initialize() async {
    setState(() {
      _isInitializing = true;
      _status = 'Inicializando...';
    });

    try {
      await FirebaseInitializer.initializeSpecialties();
      setState(() {
        _status = 'Datos inicializados correctamente';
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicializar Datos de Prueba'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.science,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Datos de Prueba',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta pantalla te permite inicializar datos de prueba en Firebase.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (_status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _status,
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isInitializing ? null : _initialize,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: _isInitializing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Inicializar Especialidades'),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ Solo ejecutar una vez',
                style: TextStyle(
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
