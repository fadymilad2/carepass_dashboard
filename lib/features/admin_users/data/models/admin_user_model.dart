import '../../domain/entities/admin_user_entity.dart';
import '../../../../core/utils/reporting.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.permissions,
    required super.isActive,
    required super.createdAt,
    super.lastLogin,
  });

  factory AdminUserModel.fromFirestore(Map<String, dynamic> data, String id) {
    final role = AdminRole.fromString(data['role']);

    final permissions = _readStoredPermissions(data);

    return AdminUserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: role,
      permissions: permissions,
      isActive: data['isActive'] == true,
      createdAt: reportDateString(data['createdAt']),
      lastLogin: data['lastLogin'] == null
          ? null
          : reportDateString(data['lastLogin']),
    );
  }

  static List<String> _readStoredPermissions(Map<String, dynamic> data) {
    final raw = data['permissions'] as List<dynamic>?;
    if (raw == null || raw.isEmpty) return [];
    return raw.map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'role': role.key,
    'permissions': permissions,
    'isActive': isActive,
    'createdAt': createdAt.isNotEmpty
        ? createdAt
        : DateTime.now().toIso8601String(),
  };
}
