import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carepass_dashboard/core/utils/reporting.dart';
import 'package:carepass_dashboard/core/utils/push_outcome.dart';
import 'package:carepass_dashboard/core/utils/receipt_csv.dart';
import 'package:carepass_dashboard/features/auth/data/datasources/auth_datasource.dart';
import 'package:carepass_dashboard/features/payments/data/datasources/payments_datasource.dart';
import 'package:carepass_dashboard/features/payments/data/repositories/payments_repository_impl.dart';
import 'package:carepass_dashboard/features/payments/domain/usecases/payments_usecases.dart';
import 'package:carepass_dashboard/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:carepass_dashboard/features/overview/data/datasources/overview_datasource.dart';
import 'package:carepass_dashboard/features/overview/data/repositories/overview_repository_impl.dart';
import 'package:carepass_dashboard/features/overview/domain/usecases/get_overview.dart';
import 'package:carepass_dashboard/features/overview/domain/entities/overview_entities.dart';
import 'package:carepass_dashboard/features/users/data/datasources/users_datasource.dart';
import 'package:carepass_dashboard/features/discount_codes/data/datasources/discount_datasource.dart';
import 'package:carepass_dashboard/features/discount_codes/data/models/discount_model.dart';

const planId = 'e1b7d9de-5be6-4692-81e4-9db1ddb0d597';

class TestUser extends Fake implements User {
  @override
  String get uid => 'member';
}

class TestAuth extends Fake implements FirebaseAuth {
  User? user = TestUser();
  bool signedOut = false;
  @override
  User? get currentUser => user;
  @override
  Future<void> signOut() async {
    signedOut = true;
    user = null;
  }
}

class BrokenChart extends Fake implements OverviewDataSource {
  @override
  Future<OverviewStats> getStats() async => const OverviewStats(
    totalUsers: 1,
    activeMembers: 1,
    totalProviders: 1,
    monthlyRevenue: 1,
    newUsersThisMonth: 1,
    revenueGrowth: 0,
  );
  @override
  Future<List<RevenuePoint>> getRevenueChart() async =>
      throw StateError('Permission denied');
  @override
  Future<List<PlanData>> getPlanDistribution() async => [];
  @override
  Future<List<RecentTransaction>> getRecentTransactions() async => [];
}

Future<void> seed(FakeFirebaseFirestore db) async {
  await db.collection('subscription_plans').doc(planId).set({
    'name': 'Family Care',
    'isActive': true,
  });
  await db.collection('users').doc('member').set({
    'username': 'Member',
    'email': 'member@example.com',
    'phoneNumber': '233123456789',
    'planName': planId,
    'subscriptionStatus': 'active',
    'createdAt': Timestamp.fromDate(DateTime.now().toUtc()),
    'cardExpiryDate': DateTime.now()
        .toUtc()
        .add(const Duration(days: 10))
        .toIso8601String(),
  });
}

Future<void> receipt(
  FakeFirebaseFirestore db,
  String id, {
  String? env = 'live',
  double amount = 10,
  String currency = 'GHS',
  String status = 'success',
  dynamic date,
  String plan = planId,
}) async {
  await db
      .collection('users')
      .doc('member')
      .collection('payments')
      .doc(id)
      .set({
        'reference': id,
        'planId': plan,
        'amount': amount,
        'currency': currency,
        'status': status,
        'environment': ?env,
        'createdAt': date ?? DateTime.now().toUtc().toIso8601String(),
      });
}

Future<PaymentsLoaded> send(PaymentsBloc bloc, PaymentsEvent event) {
  final next = bloc.stream
      .where((s) => s is PaymentsLoaded)
      .cast<PaymentsLoaded>()
      .first
      .timeout(const Duration(seconds: 3));
  bloc.add(event);
  return next;
}

void main() {
  test(
    'revenue excludes sandbox, unknown environments, failures and other currencies',
    () async {
      final db = FakeFirebaseFirestore();
      await seed(db);
      await receipt(db, 'live', amount: 12);
      await receipt(db, 'sandbox', env: 'sandbox', amount: 900);
      await receipt(db, 'legacy', env: null, amount: 800);
      await receipt(db, 'usd', currency: 'USD', amount: 700);
      await receipt(db, 'failed', status: 'failed', amount: 600);
      final overview = OverviewDataSourceImpl(db);
      expect((await overview.getStats()).monthlyRevenue, 12);
      expect((await overview.getRevenueChart()).last.amount, 12);
      expect((await overview.getRecentTransactions()).single.reference, 'live');
      final payments = PaymentsDataSourceImpl(db);
      expect((await payments.getPaymentSummary()).totalRevenue, 12);
      expect((await payments.getPayments()).length, 5);
      expect(
        (await payments.getPayments())
            .firstWhere((p) => p.reference == 'legacy')
            .environment,
        'unknown',
      );
    },
  );
  test(
    'actual plan UUIDs resolve and expired active records are not counted',
    () async {
      final db = FakeFirebaseFirestore();
      await seed(db);
      await db.collection('users').doc('expired').set({
        'planName': planId,
        'subscriptionStatus': 'active',
        'cardExpiryDate': '2020-01-01T00:00:00Z',
      });
      final overview = OverviewDataSourceImpl(db);
      expect((await overview.getStats()).activeMembers, 1);
      expect((await overview.getPlanDistribution()).single.plan, 'Family Care');
      final users = await UsersDataSourceImpl(db).getUsers();
      expect(users.length, 2); // Missing createdAt no longer hides an account.
      expect(users.firstWhere((u) => u.id == 'member').planName, 'Family Care');
      expect(
        users.firstWhere((u) => u.id == 'expired').subscriptionStatus,
        'expired',
      );
    },
  );
  test('history and search include matches beyond 100 receipts', () async {
    final db = FakeFirebaseFirestore();
    await seed(db);
    for (var i = 0; i < 105; i++) {
      await receipt(
        db,
        'receipt-$i',
        date: DateTime.utc(
          2026,
          1,
          1,
        ).add(Duration(minutes: i)).toIso8601String(),
      );
    }
    final ds = PaymentsDataSourceImpl(db);
    expect((await ds.getPayments()).length, 105);
    expect(
      (await ds.searchPayments('receipt-0')).single.reference,
      'receipt-0',
    );
    final rows = await ds.getPayments();
    expect(receiptCsv(rows).split('\r\n').length, 106);
  });
  test(
    'same-day filter includes midnight and end of day, but not next day',
    () async {
      final db = FakeFirebaseFirestore();
      await seed(db);
      await receipt(db, 'start', date: '2026-09-20T00:00:00Z');
      await receipt(
        db,
        'end',
        date: Timestamp.fromDate(DateTime.utc(2026, 9, 20, 23, 59, 59)),
      );
      await receipt(db, 'next', date: '2026-09-21T00:00:00Z');
      final rows = await PaymentsDataSourceImpl(
        db,
      ).getPayments(from: DateTime(2026, 9, 20), to: DateTime(2026, 9, 20));
      expect(rows.map((p) => p.reference), unorderedEquals(['start', 'end']));
    },
  );
  test('combined search retains plan, date and status filters', () async {
    final db = FakeFirebaseFirestore();
    await seed(db);
    await receipt(db, 'match', date: '2026-09-20T12:00:00Z');
    await receipt(
      db,
      'other-plan',
      plan: 'other',
      date: '2026-09-20T12:00:00Z',
    );
    await receipt(
      db,
      'other-status',
      status: 'failed',
      date: '2026-09-20T12:00:00Z',
    );
    final repo = PaymentsRepositoryImpl(PaymentsDataSourceImpl(db));
    final bloc = PaymentsBloc(
      get: GetPayments(repo),
      getSummary: GetPaymentSummary(repo),
      search: SearchPayments(repo),
      export: ExportPaymentsCsv(repo),
    );
    addTearDown(bloc.close);
    await send(bloc, PaymentsLoadRequested());
    await send(
      bloc,
      PaymentsFilterApplied(
        planFilter: planId,
        statusFilter: 'success',
        from: DateTime(2026, 9, 20),
        to: DateTime(2026, 9, 20),
      ),
    );
    final state = await send(bloc, PaymentsSearchChanged('member@example.com'));
    expect(state.filtered.single.reference, 'match');
    expect(state.payments.length, 3);
    expect(state.filtered.single.planLabel, 'Family Care');
    final exported = bloc.stream.firstWhere((s) => s is PaymentsExportReady);
    bloc.add(PaymentsExportRequested());
    expect(
      (await exported as PaymentsExportReady).csvContent,
      contains('Family Care'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state, isA<PaymentsLoaded>());
  });
  test(
    'discount reads server counter and edit does not reset counters',
    () async {
      final db = FakeFirebaseFirestore();
      final ref = db.collection('discount_codes').doc('code');
      await ref.set({
        'code': 'HALF',
        'discount': 50,
        'type': 'percent',
        'isActive': true,
        'maxUses': 10,
        'currentUses': 7,
        'usedCount': 1,
        'createdAt': '2026-01-01T00:00:00Z',
      });
      final ds = DiscountDataSourceImpl(db);
      final model = (await ds.getCodes()).single;
      expect(model.usedCount, 7);
      await ref.update({'currentUses': 8});
      await ds.updateCode(model.copyWithFields(description: 'Changed'));
      expect((await ref.get()).data()!['currentUses'], 8);
      await ds.createCode(
        DiscountCodeModel.empty().copyWithFields(code: 'NEW'),
      );
      final created = await db
          .collection('discount_codes')
          .where('code', isEqualTo: 'NEW')
          .get();
      expect(created.docs.single.data()['currentUses'], 0);
    },
  );
  test(
    'partial overview read failure remains an error instead of empty chart',
    () async {
      final result = await GetOverviewData(
        OverviewRepositoryImpl(BrokenChart()),
      )();
      expect(result.isLeft(), isTrue);
      expect(result.fold((e) => e, (_) => ''), contains('Permission denied'));
    },
  );
  for (final state in ['missing', 'inactive', 'active']) {
    test('admin restoration checks $state record', () async {
      final db = FakeFirebaseFirestore();
      final auth = TestAuth();
      if (state != 'missing') {
        await db.collection('admin_users').doc('member').set({
          'role': 'super_admin',
          'isActive': state == 'active',
          'name': 'Admin',
          'email': 'admin@example.com',
        });
      }
      final admin = await AuthDataSourceImpl(
        auth: auth,
        db: db,
      ).getCurrentAdmin();
      expect(admin != null, state == 'active');
      expect(auth.signedOut, state != 'active');
      if (state == 'missing') {
        expect(
          (await db.collection('admin_users').doc('member').get()).exists,
          isFalse,
        );
      }
    });
  }
  test(
    'unknown plans and invalid expiry never fabricate Standard or active',
    () {
      expect(resolvePlanLabel(planId, {}), contains(planId));
      expect(
        effectiveStatus({'subscriptionStatus': 'active'}, DateTime.now()),
        'unknown',
      );
      expect(
        isActiveAdminRecord({'role': 'super_admin', 'isActive': false}),
        isFalse,
      );
    },
  );
  test(
    'push failures and broadcasts are distinguished from delivery counts',
    () {
      expect(
        PushOutcome.fromResponse(
          {'sent': 0, 'error': 'denied'},
          broadcast: true,
          requested: 0,
        ).completed,
        isFalse,
      );
      final broadcast = PushOutcome.fromResponse(
        {'sent': -1},
        broadcast: true,
        requested: 0,
      );
      expect(broadcast.completed, isTrue);
      expect(broadcast.acceptedCount, isNull);
      expect(
        PushOutcome.fromResponse(
          {'sent': 1},
          broadcast: false,
          requested: 2,
        ).status,
        'partial',
      );
    },
  );
  test(
    'CSV preserves quotes/newlines and neutralizes spreadsheet formulas',
    () async {
      final db = FakeFirebaseFirestore();
      await seed(db);
      await db.collection('users').doc('member').update({
        'username': '=SUM(1,2) "name"\nnext',
      });
      await receipt(db, 'csv');
      final csv = receiptCsv(await PaymentsDataSourceImpl(db).getPayments());
      expect(csv, contains("'="));
      expect(csv, contains('""name""'));
      expect(csv, contains('Environment'));
    },
  );
  test('report boundaries use UTC and accept Timestamp values', () {
    final start = DateTime.utc(2026, 9), end = DateTime.utc(2026, 10);
    expect(inReportRange(Timestamp.fromDate(start), start, end), isTrue);
    expect(inReportRange(end.toIso8601String(), start, end), isFalse);
    expect(reportDate('2026-09-01T00:00:00'), start);
  });
}
