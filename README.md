# AbogaNet - Plataforma de Servicios Legales

Aplicación móvil desarrollada en Flutter con Firebase para conectar clientes con abogados profesionales.

## 🎯 Características Principales

### Para Clientes (HU-C)
- **HU-C1**: Buscar abogados por especialidad y reservar consultas
- **HU-C2**: Subir y compartir documentos de forma segura
- **HU-C3**: Recibir resúmenes y actas de consultas
- **HU-C4**: Ver historial de consultas y estado de casos

### Para Abogados (HU-E1, HU-E2)
- Ver agenda y citas programadas
- Gestionar casos asignados
- Subir actas y documentos
- Actualizar estado de casos

### Para Administradores (HU-E3)
- Clasificar consultas por especialidad
- Asignar abogados a casos
- Supervisar operaciones

### Para Gestores (HU-E4)
- Facturar consultas
- Ver reportes de ingresos
- Análisis por abogado

## 🏗️ Arquitectura

### Modelos
- `AppUser`: Usuarios del sistema
- `Lawyer`: Perfil de abogados
- `Appointment`: Citas/consultas
- `LegalCase`: Casos legales
- `Document`: Documentos compartidos
- `CaseNote`: Actas y notas
- `Invoice`: Facturas
- `Specialty`: Especialidades legales

### Servicios
- `AuthService`: Autenticación con Firebase Auth
- `FirestoreService`: CRUD operations con Firestore
- `StorageService`: Gestión de archivos con Firebase Storage

### Providers (State Management)
- `AuthProvider`: Estado de autenticación
- `LawyerProvider`: Gestión de abogados
- `AppointmentProvider`: Gestión de citas
- `CaseProvider`: Gestión de casos
- `DocumentProvider`: Gestión de documentos
- `InvoiceProvider`: Gestión de facturas

## 🚀 Configuración

### 1. Requisitos Previos
- Flutter SDK >= 3.10.1
- Dart >= 3.10.1
- Firebase CLI
- Android Studio / Xcode (para desarrollo móvil)

### 2. Configurar Firebase

#### Opción A: Usar FlutterFire CLI (Recomendado)
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para el proyecto
flutterfire configure
```

Esto generará automáticamente el archivo `firebase_options.dart` con las configuraciones correctas.

#### Opción B: Configuración Manual
1. Crear un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Agregar apps Android/iOS al proyecto
3. Descargar `google-services.json` (Android) y colocarlo en `android/app/`
4. Descargar `GoogleService-Info.plist` (iOS) y colocarlo en `ios/Runner/`
5. Actualizar `lib/firebase_options.dart` con tus credenciales

### 3. Habilitar Servicios en Firebase Console

#### Authentication
1. Ir a Authentication > Sign-in method
2. Habilitar "Email/Password"

#### Firestore Database
1. Ir a Firestore Database
2. Crear base de datos en modo de prueba
3. Actualizar reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Usuarios
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Abogados
    match /lawyers/{lawyerId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'lawyer']);
    }
    
    // Citas
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.lawyerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager']);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.lawyerId == request.auth.uid);
    }
    
    // Casos
    match /cases/{caseId} {
      allow read: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.lawyerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin']);
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.lawyerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Documentos
    match /documents/{documentId} {
      allow read: if request.auth != null && 
        (resource.data.uploadedBy == request.auth.uid || 
         request.auth.uid in resource.data.sharedWith);
      allow create: if request.auth != null;
      allow delete: if request.auth != null && resource.data.uploadedBy == request.auth.uid;
    }
    
    // Facturas
    match /invoices/{invoiceId} {
      allow read: if request.auth != null && 
        (resource.data.clientId == request.auth.uid || 
         resource.data.lawyerId == request.auth.uid ||
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager']);
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
      allow update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'manager'];
    }
    
    // Notas de casos
    match /caseNotes/{noteId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Especialidades
    match /specialties/{specialtyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

#### Storage
1. Ir a Storage
2. Crear bucket por defecto
3. Configurar reglas de seguridad:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /documents/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 4. Instalar Dependencias
```bash
flutter pub get
```

### 5. Ejecutar la Aplicación
```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

## 📱 Roles de Usuario

### Cliente
- Email: cliente@test.com
- Rol: client

### Abogado
- Email: abogado@test.com
- Rol: lawyer

### Administrador
- Email: admin@test.com
- Rol: admin

### Gestor
- Email: gestor@test.com
- Rol: manager

## 🔧 Estructura del Proyecto

```
lib/
├── models/              # Modelos de datos
│   ├── app_user.dart
│   ├── lawyer.dart
│   ├── appointment.dart
│   ├── legal_case.dart
│   ├── document.dart
│   ├── case_note.dart
│   ├── invoice.dart
│   ├── specialty.dart
│   └── user_role.dart
├── services/            # Servicios Firebase
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── providers/           # State Management
│   ├── auth_provider.dart
│   ├── lawyer_provider.dart
│   ├── appointment_provider.dart
│   ├── case_provider.dart
│   ├── document_provider.dart
│   └── invoice_provider.dart
├── screens/            # Pantallas UI
│   ├── auth/
│   ├── client/
│   ├── lawyer/
│   ├── admin/
│   └── manager/
├── firebase_options.dart
└── main.dart
```

## 📦 Dependencias Principales

- `firebase_core`: ^3.6.0
- `firebase_auth`: ^5.3.1
- `cloud_firestore`: ^5.4.4
- `firebase_storage`: ^12.3.4
- `provider`: ^6.1.2
- `file_picker`: ^8.1.4
- `intl`: ^0.19.0
- `fl_chart`: ^0.69.0

## 🎨 Características Técnicas

- **Autenticación**: Firebase Authentication con email/password
- **Base de Datos**: Cloud Firestore en tiempo real
- **Almacenamiento**: Firebase Storage para documentos
- **State Management**: Provider pattern
- **UI**: Material Design 3
- **Seguridad**: Reglas de seguridad en Firestore y Storage

## 📝 Próximas Mejoras

- [ ] Notificaciones push con FCM
- [ ] Chat en tiempo real entre cliente y abogado
- [ ] Videollamadas integradas
- [ ] Pagos integrados (Stripe/PayPal)
- [ ] Generación de reportes en PDF
- [ ] Sistema de calificaciones y reseñas
- [ ] Multi-idioma

## 🐛 Solución de Problemas

### Error: Firebase not initialized
Asegúrate de que `firebase_options.dart` esté correctamente configurado y que hayas ejecutado `flutterfire configure`.

### Error: Google Services
Verifica que `google-services.json` (Android) esté en `android/app/` y `GoogleService-Info.plist` (iOS) en `ios/Runner/`.

### Error de permisos en Firestore
Revisa las reglas de seguridad en Firebase Console.

## 📄 Licencia

Este proyecto es de código abierto bajo la licencia MIT.

## 👥 Contribuir

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request.

## 📞 Contacto

Para soporte o consultas, contacta a través del repositorio.
