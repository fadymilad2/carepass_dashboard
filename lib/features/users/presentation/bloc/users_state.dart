part of 'users_bloc.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersUpdating extends UsersState {
  final List<UserEntity> users;
  final String filter;
  final String query;
  const UsersUpdating({
    required this.users,
    required this.filter,
    required this.query,
  });
  @override
  List<Object?> get props => [users];
}

class UsersLoaded extends UsersState {
  final List<UserEntity> allUsers;
  final List<UserEntity> filtered;
  final String statusFilter;
  final String searchQuery;
  final UserStats stats;

  const UsersLoaded({
    required this.allUsers,
    required this.filtered,
    required this.statusFilter,
    required this.searchQuery,
    required this.stats,
  });

  @override
  List<Object?> get props => [allUsers, filtered, statusFilter, searchQuery];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object?> get props => [message];
}

class UsersActionSuccess extends UsersState {
  final String message;
  final List<UserEntity> allUsers;
  final List<UserEntity> filtered;
  final String statusFilter;
  final String searchQuery;
  final UserStats stats;

  const UsersActionSuccess({
    required this.message,
    required this.allUsers,
    required this.filtered,
    required this.statusFilter,
    required this.searchQuery,
    required this.stats,
  });

  @override
  List<Object?> get props => [message, allUsers];
}

// ── BLoC ───────────────────────────────────────────────────────────────
