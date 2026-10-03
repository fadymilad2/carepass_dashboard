import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum AdminRole {
  superAdmin,
  support,
  marketer,
  custom;

  String get key {
    switch (this) {
      case AdminRole.superAdmin:
        return 'super_admin';
      case AdminRole.support:
        return 'support';
      case AdminRole.marketer:
        return 'marketer';
      case AdminRole.custom:
        return 'custom';
    }
  }

  String get label {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.support:
        return 'Support';
      case AdminRole.marketer:
        return 'Marketer';
      case AdminRole.custom:
        return 'Custom';
    }
  }

  Color get color {
    switch (this) {
      case AdminRole.superAdmin:
        return const Color(0xFFE53E3E);
      case AdminRole.support:
        return const Color(0xFF3182CE);
      case AdminRole.marketer:
        return const Color(0xFF38A169);
      case AdminRole.custom:
        return const Color(0xFF805AD5);
    }
  }

  // Presets are applied explicitly during creation or role changes.
  // Existing accounts use their stored permission grants.
  List<String> get permissions {
    switch (this) {
      case AdminRole.superAdmin:
        return [
          'view_overview',
          'manage_users',
          'manage_providers',
          'manage_services',
          'view_payments',
          'manage_plans',
          'manage_banners',
          'send_notifications',
          'manage_discount_codes',
          'manage_admin_users',
          'manage_settings',
        ];
      case AdminRole.support:
        return ['view_overview', 'manage_users', 'view_payments'];
      case AdminRole.marketer:
        return [
          'view_overview',
          'manage_banners',
          'send_notifications',
          'manage_providers',
        ];
      case AdminRole.custom:
        return [];
    }
  }

  static AdminRole fromString(String? v) {
    switch (v) {
      case 'super_admin':
        return AdminRole.superAdmin;
      case 'support':
        return AdminRole.support;
      case 'marketer':
        return AdminRole.marketer;
      case 'custom':
        return AdminRole.custom;
      default:
        return AdminRole.custom;
    }
  }

  static List<String> get allPermissions => AdminRole.superAdmin.permissions;

  // ✅ New — single source of truth for "what role does this
  // exact permission set correspond to?". Used both when saving
  // a new admin (Add Admin sheet) and when editing an existing
  // admin's permissions, so the two flows can never disagree.
  static AdminRole resolveFromPermissions(List<String> permissions) {
    final selected = Set<String>.from(permissions);
    for (final preset in [
      AdminRole.superAdmin,
      AdminRole.support,
      AdminRole.marketer,
    ]) {
      final defaults = Set<String>.from(preset.permissions);
      if (defaults.length == selected.length &&
          defaults.containsAll(selected)) {
        return preset;
      }
    }
    return AdminRole.custom;
  }
}

class PermissionInfo {
  final String key;
  final String label;
  final IconData icon;
  const PermissionInfo(this.key, this.label, this.icon);
}

const List<PermissionInfo> kAllPermissions = [
  PermissionInfo('view_overview', 'View Overview', Icons.dashboard_outlined),
  PermissionInfo('manage_users', 'Manage Users', Icons.people_outline),
  PermissionInfo(
    'manage_providers',
    'Manage Providers',
    Icons.local_hospital_outlined,
  ),
  PermissionInfo(
    'manage_services',
    'Manage Services',
    Icons.medical_services_outlined,
  ),
  PermissionInfo('view_payments', 'View Payments', Icons.payments_outlined),
  PermissionInfo('manage_plans', 'Manage Plans', Icons.credit_card_outlined),
  PermissionInfo('manage_banners', 'Manage Banners', Icons.image_outlined),
  PermissionInfo(
    'send_notifications',
    'Send Notifications',
    Icons.notifications_outlined,
  ),
  PermissionInfo(
    'manage_discount_codes',
    'Manage Discount Codes',
    Icons.discount_outlined,
  ),
  PermissionInfo(
    'manage_admin_users',
    'Manage Admin Users',
    Icons.admin_panel_settings_outlined,
  ),
  PermissionInfo('manage_settings', 'Manage Settings', Icons.settings_outlined),
];

class AdminUserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final AdminRole role;
  final List<String> permissions;
  final bool isActive;
  final String createdAt;
  final String? lastLogin;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    this.lastLogin,
  });

  bool hasPermission(String p) => permissions.contains(p);
  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    permissions,
    isActive,
    createdAt,
    lastLogin,
  ];
}

