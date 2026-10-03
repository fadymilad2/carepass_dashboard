import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';
import '../repositories/notifications_repository.dart';

class GetNotificationHistory {
  final NotificationsRepository repo;
  GetNotificationHistory(this.repo);
  Future<Either<String, List<NotificationEntity>>> call() =>
      repo.getNotificationHistory();
}

class SendNotification {
  final NotificationsRepository repo;
  SendNotification(this.repo);

  Future<Either<String, void>> call({
    required String title,
    required String body,
    required String targetGroup,
    required List<String> targetUserIds,
    required String type,
  }) => repo.sendNotification(
    title: title,
    body: body,
    targetGroup: targetGroup,
    targetUserIds: targetUserIds,
    type: type,
  );
}

class SendExpiryReminders {
  final NotificationsRepository repo;
  SendExpiryReminders(this.repo);
  Future<Either<String, void>> call() => repo.sendExpiryReminders();
}

class DeleteNotification {
  final NotificationsRepository repo;
  DeleteNotification(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteNotification(id);
}

class ClearAllNotifications {
  final NotificationsRepository repo;
  ClearAllNotifications(this.repo);
  Future<Either<String, void>> call() => repo.clearAllNotifications();
}
