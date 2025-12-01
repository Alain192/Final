import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lawyer_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/case_provider.dart';
import 'lawyer_search_screen.dart';
import 'appointments_list_screen.dart';
import 'cases_list_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
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
      Provider.of<LawyerProvider>(context, listen: false).loadLawyers();
      Provider.of<LawyerProvider>(context, listen: false).loadSpecialties();
      Provider.of<AppointmentProvider>(context, listen: false)
          .loadAppointmentsByClient(userId);
      Provider.of<CaseProvider>(context, listen: false).loadCasesByClient(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const LawyerSearchScreen(),
      const AppointmentsListScreen(),
      const CasesListScreen(),
      const ClientProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AbogaNet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Notificaciones
            },
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
            icon: Icon(Icons.search),
            label: 'Buscar',
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

class ClientProfileScreen extends StatelessWidget {
  const ClientProfileScreen({super.key});

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
        const SizedBox(height: 8),
        Chip(
          label: Text(user?.role.displayName ?? ''),
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        const SizedBox(height: 32),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Editar Perfil'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Editar perfil
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Cambiar Contraseña'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Cambiar contraseña
          },
        ),
        ListTile(
          leading: const Icon(Icons.help),
          title: const Text('Ayuda'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Ayuda
          },
        ),
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
