import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:carepass_dashboard/features/notifications/data/datasources/notifications_datasource.dart';

class FakeResult<T> extends Fake implements HttpsCallableResult<T> {
  final T value;
  FakeResult(this.value);
  @override
  T get data => value;
}

class FakeCall extends Fake implements HttpsCallable {
  final dynamic response;
  final bool fail;
  FakeCall(this.response, this.fail);
  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    if (fail) throw StateError('Connection lost');
    return FakeResult<T>(response as T);
  }
}

class FakeFunctions extends Fake implements FirebaseFunctions {
  final dynamic response;
  final bool fail;
  FakeFunctions(this.response, {this.fail = false});
  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) =>
      FakeCall(response, fail);
}

void main() {
  for (final scenario in ['failure', 'accepted', 'unknown']) {
    test('broadcast $scenario is saved accurately in history', () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('member').set({'username': 'Member'});
      final functions = FakeFunctions(
        scenario == 'accepted'
            ? {'sent': -1}
            : {'sent': 0, 'error': 'Rejected'},
        fail: scenario == 'unknown',
      );
      final source = NotificationsDataSourceImpl(db: db, functions: functions);
      final send = source.sendNotification(
        title: 'Test',
        body: 'Test',
        targetGroup: 'all',
        targetUserIds: [],
        type: 'general',
      );
      if (scenario == 'accepted') {
        expect(await send, -1);
      } else {
        await expectLater(send, throwsStateError);
      }
      final history = (await db.collection('notification_history').get())
          .docs
          .single
          .data();
      expect(history['inAppCount'], 1);
      expect(history['isSent'], scenario == 'accepted');
      expect(
        history['pushStatus'],
        scenario == 'failure' ? 'failed' : scenario,
      );
      if (scenario == 'accepted') expect(history['pushSentCount'], isNull);
      expect(
        (await source.getHistory()).single.deliveryLabel,
        isNot(contains('1 sent')),
      );
    });
  }
  test('large audience creates in-app records in bounded batches', () async {
    final db = FakeFirebaseFirestore();
    for (var i = 0; i < 501; i++) {
      await db.collection('users').doc('user$i').set({'username': 'Member'});
    }
    final source = NotificationsDataSourceImpl(
      db: db,
      functions: FakeFunctions({'sent': -1}),
    );
    await source.sendNotification(
      title: 'Test',
      body: 'Test',
      targetGroup: 'all',
      targetUserIds: [],
      type: 'general',
    );
    expect((await db.collectionGroup('notifications').get()).docs.length, 501);
  });
  test(
    'active audience excludes expired profiles and records no-token outcome',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('current').set({
        'subscriptionStatus': 'active',
        'cardExpiryDate': '2099-01-01T00:00:00Z',
      });
      await db.collection('users').doc('old').set({
        'subscriptionStatus': 'active',
        'cardExpiryDate': '2000-01-01T00:00:00Z',
      });
      final source = NotificationsDataSourceImpl(
        db: db,
        functions: FakeFunctions({'sent': 0}),
      );
      await expectLater(
        source.sendNotification(
          title: 'Test',
          body: 'Test',
          targetGroup: 'active',
          targetUserIds: [],
          type: 'general',
        ),
        throwsStateError,
      );
      final history = (await db.collection('notification_history').get())
          .docs
          .single
          .data();
      expect(history['targetUserIds'], ['current']);
      expect(history['pushStatus'], 'not_requested');
      expect(history['isSent'], false);
    },
  );
  test('clear history removes all batches beyond the first 500 rows', () async {
    final db = FakeFirebaseFirestore();
    for (var i = 0; i < 805; i++) {
      await db.collection('notification_history').doc('n$i').set({
        'title': 'Test',
      });
    }
    final source = NotificationsDataSourceImpl(
      db: db,
      functions: FakeFunctions({'sent': 0}),
    );
    await source.clearAllNotifications();
    expect((await db.collection('notification_history').get()).docs, isEmpty);
  });
}
