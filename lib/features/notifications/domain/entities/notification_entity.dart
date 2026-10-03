import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String body;
  final String type;
  final List<String> targetUserIds;
  final String targetGroup;
  final bool isSent;
  final String createdAt;
  final int sentCount;
  final String pushStatus;
  final int? pushAcceptedCount;
  String get deliveryLabel => pushStatus == 'accepted'
      ? (pushAcceptedCount == null
            ? 'Broadcast accepted; delivery unknown'
            : '$pushAcceptedCount push requests accepted')
      : 'Push: $pushStatus';

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.targetUserIds,
    required this.targetGroup,
    required this.isSent,
    required this.createdAt,
    required this.sentCount,
    this.pushStatus = 'unknown',
    this.pushAcceptedCount,
  });

  String get targetLabel {
    switch (targetGroup) {
      case 'all':
        return 'All Users';
      case 'active':
        return 'Active Members';
      case 'expired':
        return 'Expired Members';
      case 'specific':
        return '${targetUserIds.length} Users';
      default:
        return targetGroup;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'subscription_expiry':
        return 'Expiry Reminder';
      case 'promo':
        return 'Promotion';
      case 'announcement':
        return 'Announcement';
      case 'system':
        return 'System';
      default:
        return 'General';
    }
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    targetUserIds,
    targetGroup,
    isSent,
    createdAt,
    sentCount,
    pushStatus,
    pushAcceptedCount,
  ];
}
