import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../providers/document_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/legal_case.dart';
import '../../models/document.dart';
import '../../models/case_note.dart';
import '../../services/firestore_service.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  LegalCase? _legalCase;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCase();
  }

  Future<void> _loadCase() async {
    final legalCase = await _firestoreService.getCase(widget.caseId);
    setState(() {
      _legalCase = legalCase;
      _isLoading = false;
    });

    if (legalCase != null) {
      Provider.of<DocumentProvider>(context, listen: false)
          .loadDocumentsByCase(widget.caseId);
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user == null) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Subiendo documento...'),
            ],
          ),
        ),
      );

      final documentProvider = Provider.of<DocumentProvider>(context, listen: false);
      final success = await documentProvider.uploadDocument(
        file: file,
        name: fileName,
        description: 'Documento del caso',
        type: DocumentType.other,
        uploadedBy: user.id,
        uploaderName: user.name,
        caseId: widget.caseId,
        sharedWith: [_legalCase!.lawyerId],
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento subido exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir documento'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_legalCase == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Caso')),
        body: const Center(child: Text('Caso no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Caso'),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // Info del caso
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _legalCase!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_legalCase!.status.displayName),
                    backgroundColor: Theme.of(context).primaryColor,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Tabs
            const TabBar(
              tabs: [
                Tab(text: 'Detalles'),
                Tab(text: 'Documentos'),
                Tab(text: 'Actas'),
              ],
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                children: [
                  // Detalles
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(context, 'Abogado', _legalCase!.lawyerName),
                        _buildInfoRow(context, 'Especialidad', _legalCase!.specialtyName),
                        _buildInfoRow(
                          context,
                          'Fecha de creación',
                          DateFormat('dd/MM/yyyy').format(_legalCase!.createdAt),
                        ),
                        if (_legalCase!.closedAt != null)
                          _buildInfoRow(
                            context,
                            'Fecha de cierre',
                            DateFormat('dd/MM/yyyy').format(_legalCase!.closedAt!),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          'Descripción',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _legalCase!.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  // Documentos
                  Consumer<DocumentProvider>(
                    builder: (context, documentProvider, child) {
                      if (documentProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final documents = documentProvider.documents;

                      return Column(
                        children: [
                          Expanded(
                            child: documents.isEmpty
                                ? const Center(child: Text('No hay documentos'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: documents.length,
                                    itemBuilder: (context, index) {
                                      return DocumentCard(document: documents[index]);
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Actas
                  StreamBuilder<List<CaseNote>>(
                    stream: _firestoreService.getNotesByCase(widget.caseId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final notes = snapshot.data ?? [];

                      if (notes.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No hay actas registradas',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          return NoteCard(note: notes[index]);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadDocument,
        icon: const Icon(Icons.upload_file),
        label: const Text('Subir Documento'),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentCard extends StatelessWidget {
  final Document document;

  const DocumentCard({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          _getFileIcon(document.fileExtension),
          color: Theme.of(context).primaryColor,
          size: 32,
        ),
        title: Text(document.name),
        subtitle: Text(
          '${document.fileSizeFormatted} • ${DateFormat('dd/MM/yyyy').format(document.uploadedAt)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // Descargar documento
          },
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class NoteCard extends StatelessWidget {
  final CaseNote note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.note_alt, color: Colors.white),
        ),
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${note.authorName} • ${DateFormat('dd/MM/yyyy HH:mm').format(note.createdAt)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contenido/Resumen
                Text(
                  'Resumen de la Consulta',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                
                // Próximos pasos
                if (note.nextSteps != null && note.nextSteps!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Próximos Pasos',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.nextSteps!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                
                // Indicador de compartido
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      note.isSharedWithClient
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      note.isSharedWithClient
                          ? 'Visible para el cliente'
                          : 'Solo visible para el abogado',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
