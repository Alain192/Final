import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/lawyer_provider.dart';
import '../../models/appointment.dart';
import '../../models/lawyer.dart';
import 'lawyer_search_screen.dart';
import 'lawyer_detail_screen.dart';

class AppointmentsListScreen extends StatelessWidget {
  const AppointmentsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final upcomingAppointments = appointmentProvider.upcomingAppointments;
    final pastAppointments = appointmentProvider.pastAppointments;

    if (appointmentProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Próximas'),
                Tab(text: 'Pasadas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Próximas citas
                  upcomingAppointments.isEmpty
                      ? const Center(child: Text('No hay citas próximas'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: upcomingAppointments.length,
                          itemBuilder: (context, index) {
                            return AppointmentCard(
                              appointment: upcomingAppointments[index],
                            );
                          },
                        ),

                  // Citas pasadas
                  pastAppointments.isEmpty
                      ? const Center(child: Text('No hay citas pasadas'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pastAppointments.length,
                          itemBuilder: (context, index) {
                            return AppointmentCard(
                              appointment: pastAppointments[index],
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
        onPressed: () {
          _showNewAppointmentOptions(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  void _showNewAppointmentOptions(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final hasAppointments = appointmentProvider.appointments.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Reservar Nueva Cita',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buscar nuevo abogado
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAllLawyers(context);
                },
                icon: const Icon(Icons.search),
                label: const Text('Buscar Abogado'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              
              if (hasAppointments) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                
                // Reagendar con abogado anterior
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showPreviousLawyers(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Reagendar con Abogado Anterior'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllLawyers(BuildContext context) {
    final lawyerProvider = Provider.of<LawyerProvider>(context, listen: false);
    final lawyers = lawyerProvider.lawyers.where((l) => l.isAvailable).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Todos los Abogados',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Chip(
                        label: Text('${lawyers.length} disponibles'),
                        backgroundColor: Colors.green.shade50,
                        labelStyle: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: lawyers.isEmpty
                      ? const Center(
                          child: Text('No hay abogados disponibles'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: lawyers.length,
                          itemBuilder: (context, index) {
                            final lawyer = lawyers[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Theme.of(context).primaryColor,
                                  child: Text(
                                    lawyer.name.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  lawyer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      lawyer.specialties.join(', '),
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.star, 
                                          size: 16, 
                                          color: Colors.amber[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          lawyer.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'S/ ${lawyer.hourlyRate.toStringAsFixed(2)}/hora',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LawyerDetailScreen(
                                        lawyer: lawyer,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPreviousLawyers(BuildContext context) {
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final lawyerProvider = Provider.of<LawyerProvider>(context, listen: false);
    
    // Obtener abogados únicos de citas anteriores
    final lawyerIds = appointmentProvider.appointments
        .map((apt) => apt.lawyerId)
        .toSet()
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Selecciona un Abogado',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lawyerIds.length,
                itemBuilder: (context, index) {
                  final lawyerId = lawyerIds[index];
                  final appointment = appointmentProvider.appointments
                      .firstWhere((apt) => apt.lawyerId == lawyerId);
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        appointment.lawyerName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(appointment.lawyerName),
                    subtitle: Text(appointment.specialtyName),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      Navigator.pop(context);
                      
                      // Buscar el abogado completo
                      final lawyers = lawyerProvider.lawyers;
                      final lawyer = lawyers.firstWhere(
                        (l) => l.id == lawyerId,
                        orElse: () => Lawyer(
                          id: lawyerId,
                          userId: lawyerId,
                          name: appointment.lawyerName,
                          email: '',
                          phone: '',
                          specialties: [appointment.specialtyName],
                          licenseNumber: '',
                          description: '',
                          rating: 5.0,
                          consultationsCount: 0,
                          hourlyRate: appointment.amount,
                          isAvailable: true,
                          createdAt: DateTime.now(),
                        ),
                      );
                      
                      // Navegar a detalle del abogado
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LawyerDetailScreen(lawyer: lawyer),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;

  const AppointmentCard({super.key, required this.appointment});

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.confirmed:
        return Colors.blue;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                    appointment.lawyerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    appointment.status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(appointment.status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(appointment.scheduledDate),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  appointment.specialtyName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${appointment.durationMinutes} minutos',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$${appointment.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (appointment.notes != null) ...[
              const SizedBox(height: 8),
              Text(
                appointment.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
