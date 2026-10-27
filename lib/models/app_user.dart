enum UserRole { student, instructor }

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
  });

  final String id;
  final String name;
  final UserRole role;
  final String department;

  String get initials {
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
