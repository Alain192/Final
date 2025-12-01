# 📊 Estructura de Base de Datos Firestore - AbogaNet

## Colecciones Principales

### 1. 👥 users
Almacena información básica de todos los usuarios.

```javascript
{
  id: string,                    // Document ID (igual al UID de Auth)
  email: string,                 // Correo electrónico
  name: string,                  // Nombre completo
  phone: string,                 // Teléfono
  role: string,                  // "client" | "lawyer" | "admin" | "manager"
  createdAt: timestamp,          // Fecha de creación
  photoUrl: string | null        // URL de foto de perfil (opcional)
}
```

**Índices Recomendados:**
- `role` (Ascending)
- `createdAt` (Descending)

---

### 2. ⚖️ lawyers
Perfil extendido de abogados (relacionado con users).

```javascript
{
  id: string,                    // Document ID (autogenerado)
  userId: string,                // Referencia al user
  name: string,                  // Nombre del abogado
  email: string,                 // Correo
  phone: string,                 // Teléfono
  specialties: string[],         // Array de IDs de especialidades
  licenseNumber: string,         // Número de cédula/licencia
  description: string,           // Descripción profesional
  rating: number,                // Calificación (0.0 - 5.0)
  consultationsCount: number,    // Número de consultas realizadas
  hourlyRate: number,            // Tarifa por hora
  isAvailable: boolean,          // Disponible para consultas
  photoUrl: string | null,       // Foto de perfil
  createdAt: timestamp           // Fecha de creación
}
```

**Índices Recomendados:**
- `userId` (Ascending)
- `specialties` (Array)
- `isAvailable` (Ascending) + `rating` (Descending)
- `createdAt` (Descending)

---

### 3. 📅 appointments
Citas/consultas entre clientes y abogados.

```javascript
{
  id: string,                    // Document ID (autogenerado)
  clientId: string,              // ID del cliente (user)
  clientName: string,            // Nombre del cliente
  lawyerId: string,              // ID del abogado (user)
  lawyerName: string,            // Nombre del abogado
  specialtyId: string,           // ID de la especialidad
  specialtyName: string,         // Nombre de la especialidad
  scheduledDate: timestamp,      // Fecha y hora programada
  durationMinutes: number,       // Duración en minutos (default: 60)
  status: string,                // "pending" | "confirmed" | "completed" | "cancelled"
  amount: number,                // Monto a cobrar
  isPaid: boolean,               // Si está pagado
  notes: string | null,          // Notas adicionales
  meetingLink: string | null,    // Link de videollamada (opcional)
  createdAt: timestamp           // Fecha de creación
}
```

**Índices Recomendados:**
- `clientId` (Ascending) + `scheduledDate` (Descending)
- `lawyerId` (Ascending) + `scheduledDate` (Ascending)
- `status` (Ascending) + `scheduledDate` (Ascending)
- `createdAt` (Descending)

---

### 4. 📁 cases
Casos legales en gestión.

```javascript
{
  id: string,                    // Document ID (autogenerado)
  clientId: string,              // ID del cliente
  clientName: string,            // Nombre del cliente
  lawyerId: string,              // ID del abogado asignado
  lawyerName: string,            // Nombre del abogado
  specialtyId: string,           // ID de la especialidad
  specialtyName: string,         // Nombre de la especialidad
  title: string,                 // Título del caso
  description: string,           // Descripción detallada
  status: string,                // "open" | "inProgress" | "closed" | "archived"
  createdAt: timestamp,          // Fecha de creación
  closedAt: timestamp | null,    // Fecha de cierre (si aplica)
  documentIds: string[],         // Array de IDs de documentos
  noteIds: string[]              // Array de IDs de notas/actas
}
```

**Índices Recomendados:**
- `clientId` (Ascending) + `createdAt` (Descending)
- `lawyerId` (Ascending) + `createdAt` (Descending)
- `status` (Ascending) + `createdAt` (Descending)
- `specialtyId` (Ascending)

---

### 5. 📄 documents
Documentos subidos y compartidos.

```javascript
{
  id: string,                    // Document ID (autogenerado)
  name: string,                  // Nombre del archivo
  description: string,           // Descripción
  type: string,                  // "contract" | "evidence" | "report" | "agreement" | "note" | "other"
  uploadedBy: string,            // ID del usuario que subió
  uploaderName: string,          // Nombre del usuario
  caseId: string | null,         // ID del caso (opcional)
  appointmentId: string | null,  // ID de la cita (opcional)
  downloadUrl: string,           // URL de descarga de Storage
  storagePath: string,           // Ruta en Storage
  fileSizeBytes: number,         // Tamaño del archivo
  fileExtension: string,         // Extensión (.pdf, .doc, etc)
  uploadedAt: timestamp,         // Fecha de subida
  sharedWith: string[]           // Array de IDs con acceso
}
```

**Índices Recomendados:**
- `caseId` (Ascending) + `uploadedAt` (Descending)
- `uploadedBy` (Ascending) + `uploadedAt` (Descending)
- `sharedWith` (Array) + `uploadedAt` (Descending)

---

### 6. 📝 caseNotes
Actas y notas de casos/consultas.

```javascript
{
  id: string,                    // Document ID (autogenerado)
  caseId: string,                // ID del caso
  appointmentId: string,         // ID de la cita relacionada
  authorId: string,              // ID del autor (abogado)
  authorName: string,            // Nombre del autor
  title: string,                 // Título de la nota/acta
  content: string,               // Contenido detallado
  nextSteps: string | null,      // Próximos pasos (opcional)
  createdAt: timestamp,          // Fecha de creación
  isSharedWithClient: boolean    // Si el cliente puede verlo
}
```

**Índices Recomendados:**
- `caseId` (Ascending) + `createdAt` (Descending)
- `appointmentId` (Ascending)
- `authorId` (Ascending) + `createdAt` (Descending)

---

### 7. 💰 invoices
Facturas de servicios.

```javascript
{
  id: string,                    // Document ID (autogenerado)
  appointmentId: string,         // ID de la cita facturada
  clientId: string,              // ID del cliente
  clientName: string,            // Nombre del cliente
  lawyerId: string,              // ID del abogado
  lawyerName: string,            // Nombre del abogado
  amount: number,                // Monto base
  tax: number,                   // Impuestos (default: 0)
  total: number,                 // Total a pagar
  status: string,                // "pending" | "paid" | "cancelled"
  description: string,           // Descripción del servicio
  issueDate: timestamp,          // Fecha de emisión
  paidDate: timestamp | null,    // Fecha de pago (si aplica)
  paymentMethod: string | null,  // Método de pago (si aplica)
  createdAt: timestamp           // Fecha de creación
}
```

**Índices Recomendados:**
- `clientId` (Ascending) + `issueDate` (Descending)
- `lawyerId` (Ascending) + `issueDate` (Descending)
- `status` (Ascending) + `issueDate` (Descending)
- `appointmentId` (Ascending)

---

### 8. 🏷️ specialties
Especialidades legales disponibles.

```javascript
{
  id: string,                    // Document ID (predefinido: "civil", "penal", etc)
  name: string,                  // Nombre de la especialidad
  description: string,           // Descripción
  iconName: string               // Nombre del ícono (default: "gavel")
}
```

**Especialidades Predefinidas:**
- `civil`: Derecho Civil
- `penal`: Derecho Penal
- `laboral`: Derecho Laboral
- `familiar`: Derecho Familiar
- `comercial`: Derecho Comercial
- `tributario`: Derecho Tributario

---

## 🔗 Relaciones Entre Colecciones

```
users (client)
  └─── appointments
         └─── invoices
         └─── caseNotes
  └─── cases
         └─── documents
         └─── caseNotes

users (lawyer)
  └─── lawyers (perfil extendido)
  └─── appointments
  └─── cases
         └─── documents
         └─── caseNotes

specialties
  └─── lawyers.specialties[]
  └─── appointments.specialtyId
  └─── cases.specialtyId
```

---

## 📈 Consultas Comunes

### Obtener citas de un cliente
```javascript
appointments
  .where('clientId', '==', userId)
  .orderBy('scheduledDate', 'desc')
```

### Obtener abogados por especialidad
```javascript
lawyers
  .where('isAvailable', '==', true)
  .where('specialties', 'array-contains', specialtyId)
  .orderBy('rating', 'desc')
```

### Obtener casos activos de un abogado
```javascript
cases
  .where('lawyerId', '==', lawyerId)
  .where('status', 'in', ['open', 'inProgress'])
  .orderBy('createdAt', 'desc')
```

### Obtener documentos compartidos con un usuario
```javascript
documents
  .where('sharedWith', 'array-contains', userId)
  .orderBy('uploadedAt', 'desc')
```

### Obtener facturas pendientes
```javascript
invoices
  .where('status', '==', 'pending')
  .orderBy('issueDate', 'desc')
```

### Ingresos por abogado (para gestores)
```javascript
invoices
  .where('lawyerId', '==', lawyerId)
  .where('status', '==', 'paid')
  .orderBy('paidDate', 'desc')
```

---

## 🛡️ Reglas de Seguridad Resumen

- **users**: Lectura para todos autenticados, escritura solo propio perfil
- **lawyers**: Lectura para todos, escritura para admins y abogados
- **appointments**: Acceso según participación (cliente/abogado) o rol (admin/manager)
- **cases**: Acceso según participación o rol admin
- **documents**: Acceso según ownership o compartidos
- **caseNotes**: Acceso según caso relacionado
- **invoices**: Acceso según participación o rol (admin/manager)
- **specialties**: Lectura para todos, escritura solo admin

---

## 🔢 Límites y Consideraciones

### Firestore Limits
- Max document size: 1 MB
- Max array elements: 20,000
- Max nested depth: 20 levels
- Max writes per second: 10,000

### Recomendaciones
- Usar paginación para listas grandes
- Limitar arrays (documentIds, noteIds) a ~100 elementos
- Para casos con muchos documentos, considerar sub-colecciones
- Implementar caché para datos frecuentes
- Usar Firestore indexes para queries complejas

---

## 📊 Estadísticas Calculadas

### Para Dashboard Cliente
- Total de citas realizadas
- Casos activos vs cerrados
- Documentos subidos

### Para Dashboard Abogado
- Citas pendientes/confirmadas
- Casos en progreso
- Rating promedio
- Ingresos del mes

### Para Dashboard Admin
- Total usuarios por rol
- Citas por estado
- Casos por especialidad
- Abogados disponibles

### Para Dashboard Gestor
- Ingresos totales
- Facturas pendientes vs pagadas
- Ingresos por abogado
- Ingresos por mes/año

---

## 🔄 Migraciones Futuras

Si necesitas agregar campos:
1. Nuevos campos son opcionales por defecto
2. Usa valores por defecto en el código
3. Migración batch para datos existentes si es necesario

Ejemplo:
```dart
// Modelo actualizado con campo opcional
String? newField;

// En fromMap
newField: map['newField'],

// Migración (script separado)
batch.update(docRef, {'newField': defaultValue});
```
