import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/case_provider.dart';
import '../../providers/lawyer_provider.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Provider.of<AppointmentProvider>(context, listen: false).loadAllAppointments();
    Provider.of<CaseProvider>(context, listen: false).loadAllCases();
    Provider.of<LawyerProvider>(context, listen: false).loadLawyers();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Dashboard'),
                Tab(text: 'Citas'),
                Tab(text: 'Casos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const AdminDashboard(),
                  const AdminAppointmentsScreen(),
                  const AdminCasesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    final lawyerProvider = Provider.of<LawyerProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total Citas',
                value: appointmentProvider.appointments.length.toString(),
                icon: Icons.event,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Casos',
                value: caseProvider.cases.length.toString(),
                icon: Icons.folder,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Abogados',
                value: lawyerProvider.lawyers.length.toString(),
                icon: Icons.people,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Casos Abiertos',
                value: caseProvider.openCases.length.toString(),
                icon: Icons.folder_open,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminAppointmentsScreen extends StatelessWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final appointments = appointmentProvider.appointments;

    if (appointmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${appointment.clientName} - ${appointment.lawyerName}'),
            subtitle: Text(appointment.specialtyName),
            trailing: Chip(
              label: Text(appointment.status.displayName),
            ),
          ),
        );
      },
    );
  }
}

class AdminCasesScreen extends StatelessWidget {
  const AdminCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final lawyerProvider = Provider.of<LawyerProvider>(context);
    final cases = caseProvider.cases;
    final lawyers = lawyerProvider.lawyers;

    if (caseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final legalCase = cases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            title: Text(legalCase.title),
            subtitle: Text('Cliente: ${legalCase.clientName}'),
            trailing: Chip(
              label: Text(legalCase.status.displayName),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Abogado actual: ${legalCase.lawyerName}'),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Reasignar a:',
                        border: OutlineInputBorder(),
                      ),
                      items: lawyers.map((lawyer) {
                        return DropdownMenuItem(
                          value: lawyer.id,
                          child: Text(lawyer.name),
                        );
                      }).toList(),
                      onChanged: (lawyerId) async {
                        if (lawyerId != null) {
                          final lawyer = lawyers.firstWhere((l) => l.id == lawyerId);
                          await caseProvider.updateCase(legalCase.id, {
                            'lawyerId': lawyerId,
                            'lawyerName': lawyer.name,
                          });
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Caso reasignado exitosamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
