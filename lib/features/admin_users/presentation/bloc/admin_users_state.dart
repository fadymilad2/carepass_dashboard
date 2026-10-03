part of 'admin_users_bloc.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();
  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<AdminUserEntity> admins;
  const AdminUsersLoaded(this.admins);

  int get activeCount => admins.where((a) => a.isActive).length;

  @override
  List<Object?> get props => [admins];
}

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;
  final List<AdminUserEntity> admins;

  const AdminUsersActionSuccess({required this.message, required this.admins});

  @override
  List<Object?> get props => [message, admins];
}

class AdminUsersError extends AdminUsersState {
  final String message;
  final List<AdminUserEntity> admins;

  const AdminUsersError({required this.message, required this.admins});

  @override
  List<Object?> get props => [message];
}

// ── BLoC ───────────────────────────────────────────────────────────────
