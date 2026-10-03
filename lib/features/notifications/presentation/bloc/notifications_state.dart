part of 'notifications_bloc.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();
  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsSending extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<NotificationEntity> history;
  const NotificationsLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class NotificationsSentSuccess extends NotificationsState {
  final String message;
  final List<NotificationEntity> history;
  const NotificationsSentSuccess({
    required this.message,
    required this.history,
  });
  @override
  List<Object?> get props => [message, history];
}

class NotificationActionSuccess extends NotificationsState {
  final String message;
  final List<NotificationEntity> history;
  const NotificationActionSuccess({
    required this.message,
    required this.history,
  });
  @override
  List<Object?> get props => [message, history];
}

class NotificationsError extends NotificationsState {
  final String message;
  final List<NotificationEntity> history;
  const NotificationsError({required this.message, required this.history});
  @override
  List<Object?> get props => [message, history];
}

// ── BLoC ───────────────────────────────────────────────────────────────
