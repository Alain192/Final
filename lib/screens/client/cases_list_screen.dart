import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/case_provider.dart';
import '../../models/legal_case.dart';
import 'case_detail_screen.dart';

class CasesListScreen extends StatelessWidget {
  const CasesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final openCases = caseProvider.openCases;
    final closedCases = caseProvider.closedCases;

    if (caseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Activos'),
              Tab(text: 'Cerrados'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Casos activos
                openCases.isEmpty
                    ? const Center(child: Text('No hay casos activos'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: openCases.length,
                        itemBuilder: (context, index) {
                          return CaseCard(
                            legalCase: openCases[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CaseDetailScreen(
                                    caseId: openCases[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                // Casos cerrados
                closedCases.isEmpty
                    ? const Center(child: Text('No hay casos cerrados'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: closedCases.length,
                        itemBuilder: (context, index) {
                          return CaseCard(
                            legalCase: closedCases[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CaseDetailScreen(
                                    caseId: closedCases[index].id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CaseCard extends StatelessWidget {
  final LegalCase legalCase;
  final VoidCallback onTap;

  const CaseCard({
    super.key,
    required this.legalCase,
    required this.onTap,
  });

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.open:
        return Colors.blue;
      case CaseStatus.inProgress:
        return Colors.orange;
      case CaseStatus.closed:
        return Colors.green;
      case CaseStatus.archived:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      legalCase.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Chip(
                    label: Text(
                      legalCase.status.displayName,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: _getStatusColor(legalCase.status),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                legalCase.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    legalCase.lawyerName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    legalCase.specialtyName,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Creado: ${DateFormat('dd/MM/yyyy').format(legalCase.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${legalCase.documentIds.length} documentos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${legalCase.noteIds.length} notas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
