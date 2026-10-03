import '../../../../core/utils/reporting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class UsersDataSource {
  Future<List<UserModel>> getUsers();
  Future<void> updateUserStatus({
    required String userId,
    required String status,
  });
  Future<void> extendSubscription({required String userId, required int days});
}

class UsersDataSourceImpl implements UsersDataSource {
  final FirebaseFirestore _db;
  UsersDataSourceImpl(this._db);

  @override
  Future<List<UserModel>> getUsers() async {
    final snap = await _db.collection(DConstants.users).get();
    final planSnap = await _db.collection('subscription_plans').get();
    final plans = {
      for (final p in planSnap.docs) p.id: p.data()['name'] as String? ?? p.id,
    };
    final users =
        snap.docs
            .map(
              (doc) => UserModel.fromFirestore({
                ...doc.data(),
                'planName': resolvePlanLabel(
                  doc.data()['planName'] as String? ?? '',
                  plans,
                ),
              }, doc.id),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required String status,
  }) async {
    if (!const ['active', 'suspended', 'expired', 'none'].contains(status)) {
      throw ArgumentError('Invalid subscription status');
    }
    final user = _db.collection(DConstants.users).doc(userId);
    final notification = user.collection(DConstants.notifications).doc();
    final batch = _db.batch();
    batch.update(user, {'subscriptionStatus': status});
    batch.set(notification, {
      'title': _statusTitle(status),
      'body': _statusBody(status),
      'type': 'account_status',
      'isRead': false,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    await batch.commit();
  }

  @override
  Future<void> extendSubscription({
    required String userId,
    required int days,
  }) async {
    if (days <= 0) throw ArgumentError('Extension days must be positive');
    final ref = _db.collection(DConstants.users).doc(userId);
    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(ref);
      if (!doc.exists) throw StateError('Member not found');
      final now = DateTime.now().toUtc();
      final expiry = reportDate(doc.data()?['cardExpiryDate']);
      final base = expiry != null && expiry.isAfter(now) ? expiry : now;
      transaction.update(ref, {
        'cardExpiryDate': base.add(Duration(days: days)).toIso8601String(),
        'subscriptionStatus': 'active',
      });
    });
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'active':
        return 'Subscription Activated ✅';
      case 'suspended':
        return 'Account Suspended ⚠️';
      case 'expired':
        return 'Subscription Expired';
      default:
        return 'Account Update';
    }
  }

  String _statusBody(String status) {
    switch (status) {
      case 'active':
        return 'Your CarePass subscription is now active.';
      case 'suspended':
        return 'Your account has been suspended. Contact support.';
      default:
        return 'Your account status has been updated.';
    }
  }
}
