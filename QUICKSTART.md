# 🎯 Guía Rápida de Inicio - AbogaNet

## ⚡ Inicio Rápido (5 minutos)

### 1. Instalar Dependencias
```bash
cd d:\app_final\app_resp
flutter pub get
```

### 2. Configurar Firebase (FlutterFire CLI - Recomendado)
```bash
# Instalar herramientas
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login
firebase login

# Configurar
flutterfire configure
```

Selecciona o crea un proyecto y las plataformas que necesites (Android/iOS).

### 3. Habilitar Servicios en Firebase Console

#### a) Authentication
- Ve a Authentication > Sign-in method
- Habilita "Email/Password"

#### b) Firestore
- Ve a Firestore Database > Crear base de datos
- Inicia en modo de prueba
- Actualiza las reglas (ver FIREBASE_SETUP.md)

#### c) Storage
- Ve a Storage > Comenzar
- Acepta la ubicación por defecto
- Actualiza las reglas (ver FIREBASE_SETUP.md)

### 4. Inicializar Datos de Prueba (Opcional)

```bash
# Ejecutar la app
flutter run
```

Una vez que la app esté corriendo, puedes:
1. Registrar usuarios manualmente con diferentes roles
2. O usar el inicializador de datos (ver `lib/utils/firebase_initializer.dart`)

### 5. Crear Usuarios de Prueba

Registra desde la app estos usuarios:

| Rol | Email | Password | Nombre |
|-----|-------|----------|--------|
| Cliente | cliente@test.com | test123 | Juan Pérez |
| Abogado | abogado@test.com | test123 | María García |
| Admin | admin@test.com | test123 | Admin Sistema |
| Gestor | gestor@test.com | test123 | Carlos Finanzas |

### 6. Crear Perfil de Abogado

Después de registrar un usuario abogado:
1. Ve a Firebase Console > Firestore
2. Crea colección `lawyers`
3. Agrega documento con estos campos:

```json
{
  "userId": "[UID del usuario abogado]",
  "name": "María García",
  "email": "abogado@test.com",
  "phone": "+1234567890",
  "specialties": ["civil", "familiar"],
  "licenseNumber": "LAW-12345",
  "description": "Abogada especializada...",
  "rating": 4.5,
  "consultationsCount": 25,
  "hourlyRate": 75.0,
  "isAvailable": true,
  "createdAt": [timestamp actual]
}
```

## 📱 Funcionalidades por Rol

### 👤 Cliente
- ✅ Buscar abogados por especialidad
- ✅ Ver perfil de abogados
- ✅ Reservar consultas
- ✅ Subir documentos
- ✅ Ver historial de casos
- ✅ Ver citas programadas

### ⚖️ Abogado
- ✅ Ver agenda de citas
- ✅ Gestionar casos asignados
- ✅ Ver documentos de casos
- ✅ Actualizar estado de casos
- ✅ Confirmar/completar citas

### 👨‍💼 Administrador
- ✅ Ver todas las citas
- ✅ Ver todos los casos
- ✅ Asignar abogados a casos
- ✅ Supervisar operaciones

### 💰 Gestor
- ✅ Ver facturas
- ✅ Marcar facturas como pagadas
- ✅ Ver reportes de ingresos
- ✅ Gráficos de ingresos por abogado

## 🔧 Comandos Útiles

```bash
# Limpiar y reconstruir
flutter clean
flutter pub get

# Ejecutar en diferentes plataformas
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Build release
flutter build apk --release
flutter build ios --release

# Ver logs
flutter logs

# Analizar código
flutter analyze

# Formatear código
dart format .
```

## 🐛 Problemas Comunes

### Error de Firebase no inicializado
```bash
flutterfire configure
flutter clean
flutter pub get
```

### Error de Google Services
- Verifica que `google-services.json` esté en `android/app/`
- Verifica que `GoogleService-Info.plist` esté en `ios/Runner/`

### Sin abogados en la búsqueda
1. Crea usuarios con rol "lawyer"
2. Crea perfiles en colección `lawyers` en Firestore

### Error de permisos en Firestore
- Verifica que las reglas de seguridad estén correctamente configuradas
- Asegúrate de estar autenticado

## 📚 Estructura del Proyecto

```
lib/
├── models/              # 9 modelos de datos
├── services/            # 3 servicios Firebase
├── providers/           # 6 providers para state management
├── screens/            
│   ├── auth/           # Login, registro, recuperar contraseña
│   ├── client/         # 4+ pantallas del cliente
│   ├── lawyer/         # Dashboard abogado
│   ├── admin/          # Dashboard admin
│   └── manager/        # Dashboard gestor
├── utils/              # Utilidades e inicializadores
└── main.dart           # Punto de entrada
```

## 🎨 Características Implementadas

### Seguridad
- ✅ Autenticación con Firebase Auth
- ✅ Reglas de seguridad en Firestore
- ✅ Reglas de seguridad en Storage
- ✅ Validación de roles

### Funcionalidad
- ✅ Búsqueda de abogados por especialidad
- ✅ Reserva de consultas
- ✅ Gestión de documentos
- ✅ Historial de casos
- ✅ Sistema de facturación
- ✅ Reportes con gráficos
- ✅ Estados de citas y casos
- ✅ Asignación de abogados

### UI/UX
- ✅ Material Design 3
- ✅ Navegación por roles
- ✅ Responsive design
- ✅ Loading states
- ✅ Error handling
- ✅ Feedback visual

## 📞 Soporte

Si encuentras problemas:
1. Revisa FIREBASE_SETUP.md para configuración detallada
2. Verifica los logs con `flutter logs`
3. Asegúrate de que Firebase esté correctamente configurado
4. Verifica las reglas de seguridad en Firebase Console

## 🚀 Próximos Pasos

1. Configura Firebase según la guía
2. Ejecuta la app
3. Registra usuarios de prueba
4. Crea perfiles de abogados
5. Prueba todas las funcionalidades

¡Listo! Ya puedes comenzar a usar AbogaNet.
