import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/case_note.dart';
import '../../models/appointment.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class CreateNoteScreen extends StatefulWidget {
  final Appointment appointment;
  final String? caseId;

  const CreateNoteScreen({
    super.key,
    required this.appointment,
    this.caseId,
  });

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _nextStepsController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _shareWithClient = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _nextStepsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) return;

    // Si no hay caseId, usar el appointmentId como referencia
    final effectiveCaseId = widget.caseId ?? widget.appointment.id;

    final note = CaseNote(
      id: '',
      caseId: effectiveCaseId,
      appointmentId: widget.appointment.id,
      authorId: user.id,
      authorName: user.name,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      nextSteps: _nextStepsController.text.trim().isNotEmpty
          ? _nextStepsController.text.trim()
          : null,
      createdAt: DateTime.now(),
      isSharedWithClient: _shareWithClient,
    );

    try {
      await _firestoreService.createCaseNote(note);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acta creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear acta: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Acta de Consulta'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Guardar acta',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Información de la cita
            Card(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información de la Consulta',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Cliente', widget.appointment.clientName),
                    _buildInfoRow('Especialidad', widget.appointment.specialtyName),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Título del acta
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título del Acta *',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
                helperText: 'Ej: Consulta inicial - Divorcio',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese un título para el acta';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Contenido/Resumen
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Resumen de la Consulta *',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
                helperText: 'Describa los temas tratados y acuerdos alcanzados',
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingrese el resumen de la consulta';
                }
                if (value.trim().length < 20) {
                  return 'El resumen debe tener al menos 20 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Próximos pasos
            TextFormField(
              controller: _nextStepsController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Próximos Pasos (opcional)',
                prefixIcon: Icon(Icons.arrow_forward),
                border: OutlineInputBorder(),
                helperText: 'Indique las acciones a seguir o tareas pendientes',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),

            // Compartir con cliente
            Card(
              child: SwitchListTile(
                title: const Text('Compartir con cliente'),
                subtitle: const Text('El cliente podrá ver esta acta en su panel'),
                value: _shareWithClient,
                onChanged: (value) {
                  setState(() {
                    _shareWithClient = value;
                  });
                },
                secondary: Icon(
                  _shareWithClient ? Icons.visibility : Icons.visibility_off,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón guardar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveNote,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Guardando...' : 'Guardar Acta'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
