import '../../../../core/utils/reporting.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.type,
    required super.targetUserIds,
    required super.targetGroup,
    required super.isSent,
    required super.createdAt,
    required super.sentCount,
    super.pushStatus,
    super.pushAcceptedCount,
  });

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return NotificationModel(
      id: id,
      pushStatus: data['pushStatus'] as String? ?? 'unknown',
      pushAcceptedCount: data['pushSentCount'] as int?,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      targetUserIds: List<String>.from(data['targetUserIds'] ?? []),
      targetGroup: data['targetGroup'] ?? 'all',
      isSent: data['isSent'] ?? false,
      createdAt: reportDateString(data['createdAt']),
      sentCount: data['sentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'body': body,
    'type': type,
    'targetUserIds': targetUserIds,
    'targetGroup': targetGroup,
    'isSent': isSent,
    'sentCount': sentCount,
    'createdAt': DateTime.now().toIso8601String(),
  };
}
