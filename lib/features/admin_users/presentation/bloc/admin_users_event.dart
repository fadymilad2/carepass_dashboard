part of 'admin_users_bloc.dart';

abstract class AdminUsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminUsersLoadRequested extends AdminUsersEvent {}

class AdminUserCreateRequested extends AdminUsersEvent {
  final String name;
  final String email;
  final String password;
  final AdminRole role;
  final List<String> permissions;

  AdminUserCreateRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.permissions,
  });

  @override
  List<Object?> get props => [email, role, permissions];
}

class AdminUserRoleUpdateRequested extends AdminUsersEvent {
  final String adminId;
  final AdminRole newRole;

  AdminUserRoleUpdateRequested({required this.adminId, required this.newRole});

  @override
  List<Object?> get props => [adminId, newRole];
}

class AdminUserPermissionsUpdateRequested extends AdminUsersEvent {
  final String adminId;
  final List<String> permissions;

  AdminUserPermissionsUpdateRequested({
    required this.adminId,
    required this.permissions,
  });

  @override
  List<Object?> get props => [adminId, permissions];
}

class AdminUserToggleStatusRequested extends AdminUsersEvent {
  final String adminId;
  final bool isActive;

  AdminUserToggleStatusRequested({
    required this.adminId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [adminId, isActive];
}

class AdminUserDeleteRequested extends AdminUsersEvent {
  final String adminId;
  AdminUserDeleteRequested(this.adminId);
  @override
  List<Object?> get props => [adminId];
}

// ── States ─────────────────────────────────────────────────────────────
