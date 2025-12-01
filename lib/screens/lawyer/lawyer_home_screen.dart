import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/case_provider.dart';
import 'create_note_screen.dart';
import '../../models/appointment.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      Provider.of<AppointmentProvider>(context, listen: false)
          .loadAppointmentsByLawyer(userId);
      Provider.of<CaseProvider>(context, listen: false).loadCasesByLawyer(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LawyerDashboardScreen(),
      const LawyerAppointmentsScreen(),
      const LawyerCasesScreen(),
      const LawyerProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Abogado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Citas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Casos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class LawyerDashboardScreen extends StatelessWidget {
  const LawyerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final caseProvider = Provider.of<CaseProvider>(context);
    
    final upcomingAppointments = appointmentProvider.upcomingAppointments;
    final openCases = caseProvider.openCases;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estadísticas
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Citas Hoy',
                value: upcomingAppointments
                    .where((apt) => 
                      apt.scheduledDate.day == DateTime.now().day &&
                      apt.scheduledDate.month == DateTime.now().month)
                    .length
                    .toString(),
                icon: Icons.event,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Casos Activos',
                value: openCases.length.toString(),
                icon: Icons.folder_open,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Próximas citas
        Text(
          'Próximas Citas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (upcomingAppointments.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No hay citas próximas')),
            ),
          )
        else
          ...upcomingAppointments.take(5).map((appointment) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(appointment.clientName.substring(0, 1)),
                ),
                title: Text(appointment.clientName),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(appointment.scheduledDate),
                ),
                trailing: Chip(
                  label: Text(appointment.status.displayName),
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                ),
              ),
            );
          }),
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

class LawyerAppointmentsScreen extends StatelessWidget {
  const LawyerAppointmentsScreen({super.key});

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
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clientName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(appointment.scheduledDate),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Chip(
                      label: Text(appointment.status.displayName),
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                    ),
                    const Spacer(),
                    if (appointment.status == AppointmentStatus.pending)
                      TextButton(
                        onPressed: () async {
                          await appointmentProvider.confirmAppointment(appointment.id);
                        },
                        child: const Text('Confirmar'),
                      ),
                    if (appointment.status == AppointmentStatus.confirmed)
                      TextButton(
                        onPressed: () async {
                          await appointmentProvider.completeAppointment(appointment.id);
                        },
                        child: const Text('Completar'),
                      ),
                    if (appointment.status == AppointmentStatus.completed)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateNoteScreen(
                                appointment: appointment,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.note_add),
                        label: const Text('Crear Acta'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LawyerCasesScreen extends StatelessWidget {
  const LawyerCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final caseProvider = Provider.of<CaseProvider>(context);
    final cases = caseProvider.cases;

    if (caseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cases.length,
      itemBuilder: (context, index) {
        final legalCase = cases[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(legalCase.title),
            subtitle: Text(legalCase.clientName),
            trailing: Chip(
              label: Text(legalCase.status.displayName),
            ),
            onTap: () {
              // Ver detalle del caso
            },
          ),
        );
      },
    );
  }
}

class LawyerProfileScreen extends StatelessWidget {
  const LawyerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            user?.name.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(fontSize: 40, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? '',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
          onTap: () async {
            await authProvider.signOut();
            if (context.mounted) {
              Navigator.of(context).pushReplacementNamed('/login');
            }
          },
        ),
      ],
    );
  }
}
