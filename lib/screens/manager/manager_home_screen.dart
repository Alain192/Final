import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/auth_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/invoice.dart';

class ManagerHomeScreen extends StatefulWidget {
  const ManagerHomeScreen({super.key});

  @override
  State<ManagerHomeScreen> createState() => _ManagerHomeScreenState();
}

class _ManagerHomeScreenState extends State<ManagerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    Provider.of<InvoiceProvider>(context, listen: false).loadAllInvoices();
    Provider.of<AppointmentProvider>(context, listen: false).loadAllAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Gestor'),
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
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Dashboard'),
                Tab(text: 'Facturas'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  const ManagerDashboard(),
                  const ManagerInvoicesScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final totalRevenue = invoiceProvider.totalRevenue;
    final pendingInvoices = invoiceProvider.pendingInvoices;
    final paidInvoices = invoiceProvider.paidInvoices;
    final revenueByLawyer = invoiceProvider.revenueByLawyer;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Estadísticas principales
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Ingresos Totales',
                value: '\$${totalRevenue.toStringAsFixed(2)}',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Facturas Pagadas',
                value: paidInvoices.length.toString(),
                icon: Icons.check_circle,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Facturas Pendientes',
                value: pendingInvoices.length.toString(),
                icon: Icons.pending,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatCard(
                title: 'Total Facturas',
                value: invoiceProvider.invoices.length.toString(),
                icon: Icons.receipt,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Gráfico de ingresos por abogado
        if (revenueByLawyer.isNotEmpty) ...[
          Text(
            'Ingresos por Abogado',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: revenueByLawyer.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    barGroups: revenueByLawyer.entries.map((entry) {
                      final index = revenueByLawyer.keys.toList().indexOf(entry.key);
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: entry.value,
                            color: Theme.of(context).primaryColor,
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text('\$${value.toInt()}');
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final lawyer = revenueByLawyer.keys.elementAt(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                lawyer.split(' ').first,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...revenueByLawyer.entries.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(entry.key),
                trailing: Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            );
          }),
        ],
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ManagerInvoicesScreen extends StatelessWidget {
  const ManagerInvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final invoices = invoiceProvider.invoices;

    if (invoiceProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InvoiceCard(invoice: invoice);
      },
    );
  }
}

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  const InvoiceCard({super.key, required this.invoice});

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.pending:
        return Colors.orange;
      case InvoiceStatus.paid:
        return Colors.green;
      case InvoiceStatus.cancelled:
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
                Text(
                  'Factura #${invoice.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Chip(
                  label: Text(
                    invoice.status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(invoice.status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Cliente: ${invoice.clientName}'),
            Text('Abogado: ${invoice.lawyerName}'),
            Text('Fecha: ${DateFormat('dd/MM/yyyy').format(invoice.issueDate)}'),
            if (invoice.paidDate != null)
              Text('Pagado: ${DateFormat('dd/MM/yyyy').format(invoice.paidDate!)}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${invoice.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (invoice.status == InvoiceStatus.pending)
                  TextButton(
                    onPressed: () async {
                      await Provider.of<InvoiceProvider>(context, listen: false)
                          .markAsPaid(invoice.id, 'Efectivo');
                    },
                    child: const Text('Marcar como Pagada'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
