# Guía de Configuración de Firebase para AbogaNet

## Paso 1: Crear Proyecto en Firebase

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Haz clic en "Agregar proyecto"
3. Nombra tu proyecto como "AbogaNet" o el nombre que prefieras
4. Acepta los términos y crea el proyecto

## Paso 2: Configurar Firebase para Flutter

### Opción Recomendada: FlutterFire CLI

```bash
# 1. Instalar Firebase CLI (si no lo tienes)
npm install -g firebase-tools

# 2. Login en Firebase
firebase login

# 3. Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# 4. Configurar Firebase para el proyecto
cd d:\app_final\app_resp
flutterfire configure
```

Esto creará automáticamente:
- `lib/firebase_options.dart` con las configuraciones correctas
- Configurará Android e iOS automáticamente

### Opción Manual

#### Android
1. En Firebase Console, agrega una app Android
2. Paquete: `com.example.app_resp`
3. Descarga `google-services.json`
4. Colócalo en `android/app/google-services.json`

#### iOS
1. En Firebase Console, agrega una app iOS
2. Bundle ID: `com.example.appResp`
3. Descarga `GoogleService-Info.plist`
4. Colócalo en `ios/Runner/GoogleService-Info.plist`

## Paso 3: Habilitar Servicios

### Authentication
1. Ve a Authentication > Sign-in method
2. Habilita "Correo electrónico/contraseña"

### Firestore Database
1. Ve a Firestore Database
2. Crea base de datos
3. Selecciona ubicación (ej: us-central1)
4. Inicia en modo de prueba (temporalmente)
5. Ve a "Reglas" y reemplaza con:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Función helper para verificar autenticación
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Función para obtener el rol del usuario
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    // Usuarios - solo pueden leer su propio perfil o todos si están autenticados
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && request.auth.uid == userId;
    }
    
    // Abogados - lectura pública, escritura para admins y abogados
    match /lawyers/{lawyerId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && getUserRole() in ['admin', 'lawyer'];
    }
    
    // Citas - acceso según participación
    match /appointments/{appointmentId} {
      allow read: if isSignedIn() && (
        resource.data.clientId == request.auth.uid || 
        resource.data.lawyerId == request.auth.uid ||
        getUserRole() in ['admin', 'manager']
      );
      allow create: if isSignedIn();
      allow update: if isSignedIn() && (
        resource.data.clientId == request.auth.uid || 
        resource.data.lawyerId == request.auth.uid ||
        getUserRole() in ['admin']
      );
    }
    
    // Casos - acceso según participación
    match /cases/{caseId} {
      allow read: if isSignedIn() && (
        resource.data.clientId == request.auth.uid || 
        resource.data.lawyerId == request.auth.uid ||
        getUserRole() == 'admin'
      );
      allow create: if isSignedIn();
      allow update: if isSignedIn() && (
        resource.data.lawyerId == request.auth.uid ||
        getUserRole() == 'admin'
      );
    }
    
    // Documentos - acceso según compartido
    match /documents/{documentId} {
      allow read: if isSignedIn() && (
        resource.data.uploadedBy == request.auth.uid || 
        request.auth.uid in resource.data.sharedWith
      );
      allow create: if isSignedIn();
      allow update: if isSignedIn() && resource.data.uploadedBy == request.auth.uid;
      allow delete: if isSignedIn() && resource.data.uploadedBy == request.auth.uid;
    }
    
    // Notas de casos
    match /caseNotes/{noteId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && getUserRole() in ['lawyer', 'admin'];
    }
    
    // Facturas - acceso según rol
    match /invoices/{invoiceId} {
      allow read: if isSignedIn() && (
        resource.data.clientId == request.auth.uid || 
        resource.data.lawyerId == request.auth.uid ||
        getUserRole() in ['admin', 'manager']
      );
      allow write: if isSignedIn() && getUserRole() in ['admin', 'manager'];
    }
    
    // Especialidades - lectura pública, escritura admin
    match /specialties/{specialtyId} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && getUserRole() == 'admin';
    }
  }
}
```

### Storage
1. Ve a Storage
2. Crea bucket
3. Ve a "Reglas" y reemplaza con:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Documentos - solo el dueño puede escribir
    match /documents/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Fotos de perfil
    match /profiles/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Paso 4: Inicializar Colecciones (Opcional)

Puedes crear las especialidades iniciales desde Firestore Console:

**Colección: `specialties`**

Documentos:
- ID: `civil`
  - name: "Derecho Civil"
  - description: "Contratos, propiedad, herencias"
  - iconName: "gavel"

- ID: `penal`
  - name: "Derecho Penal"
  - description: "Defensa criminal, denuncias"
  - iconName: "gavel"

- ID: `laboral`
  - name: "Derecho Laboral"
  - description: "Relaciones laborales, despidos"
  - iconName: "gavel"

- ID: `familiar`
  - name: "Derecho Familiar"
  - description: "Divorcios, custodia, pensiones"
  - iconName: "gavel"

- ID: `comercial`
  - name: "Derecho Comercial"
  - description: "Empresas, sociedades, comercio"
  - iconName: "gavel"

- ID: `tributario`
  - name: "Derecho Tributario"
  - description: "Impuestos, fiscalización"
  - iconName: "gavel"

## Paso 5: Crear Usuarios de Prueba

Después de ejecutar la app, registra usuarios de prueba para cada rol:

1. **Cliente**
   - Email: cliente@test.com
   - Password: test123
   - Nombre: Juan Pérez
   - Rol: Cliente

2. **Abogado**
   - Email: abogado@test.com
   - Password: test123
   - Nombre: María García
   - Rol: Abogado
   - (Luego crear perfil de abogado en Firestore manualmente)

3. **Administrador**
   - Email: admin@test.com
   - Password: test123
   - Nombre: Admin Sistema
   - Rol: Administrador

4. **Gestor**
   - Email: gestor@test.com
   - Password: test123
   - Nombre: Carlos Finanzas
   - Rol: Gestor

## Paso 6: Crear Perfil de Abogado (Manual)

Después de registrar un usuario como abogado, crea un documento en la colección `lawyers`:

```json
{
  "userId": "[UID del usuario abogado]",
  "name": "María García",
  "email": "abogado@test.com",
  "phone": "+1234567890",
  "specialties": ["civil", "familiar"],
  "licenseNumber": "LAW-12345",
  "description": "Abogada especializada en derecho civil y familiar con 10 años de experiencia",
  "rating": 4.5,
  "consultationsCount": 25,
  "hourlyRate": 75.0,
  "isAvailable": true,
  "photoUrl": null,
  "createdAt": [timestamp actual]
}
```

## Paso 7: Verificar Configuración

```bash
# Ejecutar la app
flutter run

# Ver logs de Firebase
flutter logs
```

## Solución de Problemas Comunes

### Error: No Firebase App '[DEFAULT]' has been created
- Verifica que `Firebase.initializeApp()` se ejecute antes de `runApp()`
- Revisa que `firebase_options.dart` exista y esté correctamente configurado

### Error: Google Services
- Android: Verifica que `google-services.json` esté en `android/app/`
- iOS: Verifica que `GoogleService-Info.plist` esté en `ios/Runner/`
- Ejecuta `flutter clean` y vuelve a construir

### Error de Permisos en Firestore
- Revisa las reglas de seguridad
- Asegúrate de que el usuario esté autenticado
- Verifica que el campo `role` exista en el documento del usuario

### Error de Storage
- Verifica que el bucket de Storage esté creado
- Revisa las reglas de seguridad de Storage
- Asegúrate de tener permisos de escritura

## Comandos Útiles

```bash
# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar en Android
flutter run -d android

# Ejecutar en iOS
flutter run -d ios

# Construir APK
flutter build apk --release

# Ver logs
flutter logs

# Actualizar Firebase
flutterfire configure
```

## Recursos Adicionales

- [Documentación de Firebase](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security/start)
