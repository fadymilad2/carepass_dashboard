import 'package:equatable/equatable.dart';

class AdminEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final List<String> permissions;
  final bool isActive;

  const AdminEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.isActive,
  });

  bool get isSuperAdmin => role == 'super_admin';

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  List<Object?> get props => [id, email, name, role, permissions, isActive];
}
