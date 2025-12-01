class Specialty {
  final String id;
  final String name;
  final String description;
  final String iconName;

  Specialty({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'gavel',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
    };
  }

  factory Specialty.fromMap(Map<String, dynamic> map, String id) {
    return Specialty(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? 'gavel',
    );
  }

  // Especialidades predefinidas
  static List<Specialty> getDefaultSpecialties() {
    return [
      Specialty(
        id: 'civil',
        name: 'Derecho Civil',
        description: 'Contratos, propiedad, herencias',
      ),
      Specialty(
        id: 'penal',
        name: 'Derecho Penal',
        description: 'Defensa criminal, denuncias',
      ),
      Specialty(
        id: 'laboral',
        name: 'Derecho Laboral',
        description: 'Relaciones laborales, despidos',
      ),
      Specialty(
        id: 'familiar',
        name: 'Derecho Familiar',
        description: 'Divorcios, custodia, pensiones',
      ),
      Specialty(
        id: 'comercial',
        name: 'Derecho Comercial',
        description: 'Empresas, sociedades, comercio',
      ),
      Specialty(
        id: 'tributario',
        name: 'Derecho Tributario',
        description: 'Impuestos, fiscalización',
      ),
    ];
  }
}
