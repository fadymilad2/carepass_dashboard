import '../../../../core/utils/reporting.dart';
import '../../../../core/utils/push_outcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

abstract class NotificationsDataSource {
  Future<List<NotificationModel>> getHistory();

  Future<int> sendNotification({
    required String title,
    required String body,
    required String targetGroup,
    required List<String> targetUserIds,
    required String type,
  });

  Future<void> sendExpiryReminders();

  Future<void> deleteNotification(String id);

  Future<void> clearAllNotifications();
}

class NotificationsDataSourceImpl implements NotificationsDataSource {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  NotificationsDataSourceImpl({
    required FirebaseFirestore db,
    required FirebaseFunctions functions,
  }) : _db = db,
       _functions = functions;

  // ── Get History ────────────────────────────────────────────────────
  @override
  Future<List<NotificationModel>> getHistory() async {
    final snap = await _db
        .collection('notification_history')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snap.docs
        .map((doc) => NotificationModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ── Send Notification ✅ Fixed FCM + Guest broadcast support ──────
  @override
  Future<int> sendNotification({
    required String title,
    required String body,
    required String targetGroup,
    required List<String> targetUserIds,
    required String type,
  }) async {
    final tokens = <String>{};
    final users = <String>{};
    final now = DateTime.now().toUtc();
    if (!['all', 'active', 'expired', 'specific'].contains(targetGroup)) {
      throw ArgumentError('Invalid audience');
    }
    final docs = targetGroup == 'specific'
        ? await Future.wait(
            targetUserIds.toSet().map(
              (id) => _db.collection('users').doc(id).get(),
            ),
          )
        : (await _db.collection('users').get()).docs;
    for (final doc in docs) {
      final data = doc.data();
      if (data == null) continue;
      final status = effectiveStatus(data, now);
      if (targetGroup == 'active' && status != 'active') continue;
      if (targetGroup == 'expired' && status != 'expired') continue;
      users.add(doc.id);
      final token = data['fcmToken'];
      if (token is String && token.isNotEmpty) tokens.add(token);
    }
    final id = const Uuid().v4();
    final ids = users.toList();
    for (var start = 0; start < ids.length; start += 400) {
      final batch = _db.batch();
      for (final uid in ids.skip(start).take(400)) {
        batch.set(
          _db.collection('users').doc(uid).collection('notifications').doc(id),
          {
            'title': title,
            'body': body,
            'type': type,
            'isRead': false,
            'createdAt': now.toIso8601String(),
          },
        );
      }
      await batch.commit();
    }
    final broadcast = targetGroup == 'all';
    var outcome = const PushOutcome(0, 'not_requested');
    if (broadcast || tokens.isNotEmpty) {
      try {
        final response = await _functions
            .httpsCallable(
              'sendPushNotification',
              options: HttpsCallableOptions(
                timeout: const Duration(seconds: 30),
              ),
            )
            .call({
              if (broadcast)
                'topic': 'all_users'
              else
                'tokens': tokens.toList(),
              'title': title,
              'body': body,
              'data': {'type': type},
            });
        outcome = PushOutcome.fromResponse(
          response.data,
          broadcast: broadcast,
          requested: tokens.length,
        );
      } catch (_) {
        outcome = const PushOutcome(null, 'unknown');
      }
    }
    await _db.collection('notification_history').doc(id).set({
      'title': title,
      'body': body,
      'type': type,
      'targetGroup': targetGroup,
      'targetUserIds': ids,
      'isSent': outcome.completed,
      'sentCount': outcome.acceptedCount ?? 0,
      'pushSentCount': outcome.acceptedCount,
      'pushStatus': outcome.status,
      'inAppCount': ids.length,
      'createdAt': now.toIso8601String(),
    });
    if (!outcome.completed) {
      throw StateError(
        'Saved in-app for ${ids.length} users. Push status: ${outcome.status}. Delivery is not confirmed; review history before retrying.',
      );
    }
    return outcome.acceptedCount ?? -1;
  }

  // ── Send Expiry Reminders ─────────────────────────────────────────
  @override
  Future<void> sendExpiryReminders() async {
    final callable = _functions.httpsCallable(
      'triggerExpiryRemindersManually',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 60)),
    );
    await callable.call({});
  }

  // ── Delete Notification from History ──────────────────────────────
  @override
  Future<void> deleteNotification(String id) async {
    await _db.collection('notification_history').doc(id).delete();
  }

  // ── Clear All Notifications from History ──────────────────────────
  @override
  Future<void> clearAllNotifications() async {
    while (true) {
      final snap = await _db
          .collection('notification_history')
          .limit(400)
          .get();
      if (snap.docs.isEmpty) return;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
