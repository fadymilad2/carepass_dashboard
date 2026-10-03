import '../../domain/entities/admin_entity.dart';

class AdminModel extends AdminEntity {
  const AdminModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.permissions,
    required super.isActive,
  });

  factory AdminModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AdminModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'support',
      permissions: List<String>.from(data['permissions'] ?? []),
      isActive: data['isActive'] ?? true,
    );
  }

  // Default super admin — لأول مرة قبل ما تضيف record في Firestore
  factory AdminModel.superAdmin({required String id, required String email}) {
    return AdminModel(
      id: id,
      email: email,
      name: 'Super Admin',
      role: 'super_admin',
      permissions: [
        'view_overview',
        'manage_users',
        'manage_providers',
        'view_payments',
        'manage_banners',
        'send_notifications',
        'manage_discount_codes',
        'manage_admin_users',
      ],
      isActive: true,
    );
  }
}
