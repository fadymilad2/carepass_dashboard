part of 'notifications_bloc.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();
  @override
  List<Object?> get props => [];
}

class NotificationsHistoryRequested extends NotificationsEvent {}

class NotificationSendRequested extends NotificationsEvent {
  final String title;
  final String body;
  final String targetGroup;
  final List<String> targetUserIds;
  final String type;

  const NotificationSendRequested({
    required this.title,
    required this.body,
    required this.targetGroup,
    required this.targetUserIds,
    required this.type,
  });

  @override
  List<Object?> get props => [title, targetGroup];
}

class NotificationExpiryRemindersRequested extends NotificationsEvent {}

class NotificationDeleteRequested extends NotificationsEvent {
  final String id;
  const NotificationDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class NotificationsClearAllRequested extends NotificationsEvent {}

// ── States ─────────────────────────────────────────────────────────────
