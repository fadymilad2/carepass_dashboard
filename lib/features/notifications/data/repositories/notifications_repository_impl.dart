import 'package:dartz/dartz.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsDataSource _ds;
  NotificationsRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<NotificationEntity>>>
  getNotificationHistory() async {
    try {
      return Right(await _ds.getHistory());
    } catch (e) {
      return Left('Failed to load history: $e');
    }
  }

  @override
  Future<Either<String, void>> sendNotification({
    required String title,
    required String body,
    required String targetGroup,
    required List<String> targetUserIds,
    required String type,
  }) async {
    try {
      await _ds.sendNotification(
        title: title,
        body: body,
        targetGroup: targetGroup,
        targetUserIds: targetUserIds,
        type: type,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to send: $e');
    }
  }

  @override
  Future<Either<String, void>> sendExpiryReminders() async {
    try {
      await _ds.sendExpiryReminders();
      return const Right(null);
    } catch (e) {
      return Left('Failed to send reminders: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteNotification(String id) async {
    try {
      await _ds.deleteNotification(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete notification: $e');
    }
  }

  @override
  Future<Either<String, void>> clearAllNotifications() async {
    try {
      await _ds.clearAllNotifications();
      return const Right(null);
    } catch (e) {
      return Left('Failed to clear all notifications: $e');
    }
  }
}
