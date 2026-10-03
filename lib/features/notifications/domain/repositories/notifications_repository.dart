import 'package:dartz/dartz.dart';
import '../entities/notification_entity.dart';

abstract class NotificationsRepository {
  Future<Either<String, List<NotificationEntity>>> getNotificationHistory();

  Future<Either<String, void>> sendNotification({
    required String title,
    required String body,
    required String targetGroup,
    required List<String> targetUserIds,
    required String type,
  });

  Future<Either<String, void>> sendExpiryReminders();

  Future<Either<String, void>> deleteNotification(String id);

  Future<Either<String, void>> clearAllNotifications();
}
