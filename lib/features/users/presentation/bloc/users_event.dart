part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersLoadRequested extends UsersEvent {}

class UsersSearchChanged extends UsersEvent {
  final String query;
  UsersSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class UsersFilterChanged extends UsersEvent {
  final String status;
  UsersFilterChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class UserStatusUpdateRequested extends UsersEvent {
  final String userId;
  final String status;
  UserStatusUpdateRequested({required this.userId, required this.status});
  @override
  List<Object?> get props => [userId, status];
}

class UserExtendSubscriptionRequested extends UsersEvent {
  final String userId;
  final int days;
  UserExtendSubscriptionRequested({required this.userId, required this.days});
  @override
  List<Object?> get props => [userId, days];
}

// ── States ─────────────────────────────────────────────────────────────
