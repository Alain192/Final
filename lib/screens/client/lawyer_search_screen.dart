import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/lawyer_provider.dart';
import '../../models/lawyer.dart';
import 'lawyer_detail_screen.dart';

class LawyerSearchScreen extends StatefulWidget {
  const LawyerSearchScreen({super.key});

  @override
  State<LawyerSearchScreen> createState() => _LawyerSearchScreenState();
}

class _LawyerSearchScreenState extends State<LawyerSearchScreen> {
  String? _selectedSpecialtyId;

  @override
  Widget build(BuildContext context) {
    final lawyerProvider = Provider.of<LawyerProvider>(context);
    final specialties = lawyerProvider.specialties;
    final lawyers = _selectedSpecialtyId == null
        ? lawyerProvider.lawyers
        : lawyerProvider.filteredLawyers;

    return Column(
      children: [
        // Filtro por especialidad
        if (specialties.isNotEmpty)
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _selectedSpecialtyId == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialtyId = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...specialties.map((specialty) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(specialty.name),
                      selected: _selectedSpecialtyId == specialty.id,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSpecialtyId = selected ? specialty.id : null;
                        });
                        lawyerProvider.setSelectedSpecialty(
                          selected ? specialty.id : null,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

        // Lista de abogados
        Expanded(
          child: lawyerProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : lawyers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se encontraron abogados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: lawyers.length,
                      itemBuilder: (context, index) {
                        final lawyer = lawyers[index];
                        return LawyerCard(
                          lawyer: lawyer,
                          onTap: () {
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
      ],
    );
  }
}

class LawyerCard extends StatelessWidget {
  final Lawyer lawyer;
  final VoidCallback onTap;

  const LawyerCard({
    super.key,
    required this.lawyer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  lawyer.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 28, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyer.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lawyer.specialties.join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          lawyer.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '${lawyer.consultationsCount} consultas',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${lawyer.hourlyRate.toStringAsFixed(2)}/hora',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
