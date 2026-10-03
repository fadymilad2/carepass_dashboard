import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/reporting.dart';
import '../../domain/entities/overview_entities.dart';

abstract class OverviewDataSource {
  Future<OverviewStats> getStats();
  Future<List<RevenuePoint>> getRevenueChart();
  Future<List<PlanData>> getPlanDistribution();
  Future<List<RecentTransaction>> getRecentTransactions();
}

class OverviewDataSourceImpl implements OverviewDataSource {
  final FirebaseFirestore _db;
  OverviewDataSourceImpl(this._db);
  Future<List<Map<String, dynamic>>>? _pendingPayments;
  // Coalesce concurrent overview reads without retaining stale cached data.
  Future<List<Map<String, dynamic>>> _payments() => _pendingPayments ??= _db
      .collectionGroup('payments')
      .get()
      .then(
        (snap) => snap.docs
            .map(
              (doc) => {
                ...doc.data(),
                'userId': doc.reference.parent.parent?.id ?? '',
              },
            )
            .toList(),
      )
      .whenComplete(() => _pendingPayments = null);
  Future<Map<String, String>> _plans() async {
    final snap = await _db.collection('subscription_plans').get();
    return {
      for (final d in snap.docs) d.id: d.data()['name'] as String? ?? d.id,
    };
  }

  @override
  Future<OverviewStats> getStats() async {
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month);
    final end = DateTime.utc(now.year, now.month + 1);
    final previous = DateTime.utc(now.year, now.month - 1);
    final users = await _db.collection('users').get();
    final providers = await _db
        .collection('providers')
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    final payments = (await _payments()).where(isLiveRevenue).toList();
    double sum(DateTime a, DateTime b) => payments
        .where((p) => inReportRange(p['createdAt'], a, b))
        .fold(0.0, (total, p) => total + receiptAmount(p));
    final revenue = sum(start, end), last = sum(previous, start);
    return OverviewStats(
      totalUsers: users.size,
      activeMembers: users.docs
          .where((d) => isCurrentMember(d.data(), now))
          .length,
      totalProviders: providers.count ?? 0,
      monthlyRevenue: revenue,
      newUsersThisMonth: users.docs
          .where((d) => inReportRange(d.data()['createdAt'], start, end))
          .length,
      revenueGrowth: last > 0 ? (revenue - last) / last * 100 : 0,
    );
  }

  @override
  Future<List<RevenuePoint>> getRevenueChart() async {
    final now = DateTime.now().toUtc();
    final payments = (await _payments()).where(isLiveRevenue).toList();
    return [
      for (int i = 5; i >= 0; i--)
        RevenuePoint(
          month: DateFormat(
            'MMM',
          ).format(DateTime.utc(now.year, now.month - i)),
          amount: payments
              .where(
                (p) => inReportRange(
                  p['createdAt'],
                  DateTime.utc(now.year, now.month - i),
                  DateTime.utc(now.year, now.month - i + 1),
                ),
              )
              .fold(0.0, (total, p) => total + receiptAmount(p)),
        ),
    ];
  }

  @override
  Future<List<PlanData>> getPlanDistribution() async {
    final plans = await _plans();
    final users = await _db.collection('users').get();
    final now = DateTime.now().toUtc();
    final counts = <String, int>{};
    for (final user in users.docs.where(
      (u) => isCurrentMember(u.data(), now),
    )) {
      final label = resolvePlanLabel(
        user.data()['planName'] as String? ?? '',
        plans,
      );
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);
    return counts.entries
        .map(
          (e) => PlanData(
            plan: e.key,
            count: e.value,
            percent: total == 0 ? 0 : e.value / total * 100,
          ),
        )
        .toList();
  }

  @override
  Future<List<RecentTransaction>> getRecentTransactions() async {
    final plans = await _plans();
    final payments = (await _payments()).where(isLiveRevenue).toList()
      ..sort(
        (a, b) => reportDateString(
          b['createdAt'],
        ).compareTo(reportDateString(a['createdAt'])),
      );
    return payments
        .take(8)
        .map(
          (p) => RecentTransaction(
            reference: p['reference'] as String? ?? '—',
            planId: resolvePlanLabel(p['planId'] as String? ?? '', plans),
            amount: receiptAmount(p),
            currency: p['currency'],
            status: p['status'],
            date: reportDateString(p['createdAt']),
            userId: p['userId'],
          ),
        )
        .toList();
  }
}
