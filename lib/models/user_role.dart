enum UserRole {
  client,
  lawyer,
  admin,
  manager;

  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'Cliente';
      case UserRole.lawyer:
        return 'Abogado';
      case UserRole.admin:
        return 'Administrador';
      case UserRole.manager:
        return 'Gestor';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'client':
      case 'cliente':
        return UserRole.client;
      case 'lawyer':
      case 'abogado':
        return UserRole.lawyer;
      case 'admin':
      case 'administrador':
        return UserRole.admin;
      case 'manager':
      case 'gestor':
        return UserRole.manager;
      default:
        return UserRole.client;
    }
  }
}
