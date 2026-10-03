import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/reporting.dart';
import '../models/payment_model.dart';
import '../../domain/entities/payment_entity.dart';

abstract class PaymentsDataSource {
  Future<List<PaymentModel>> getPayments({
    String? statusFilter,
    String? planFilter,
    DateTime? from,
    DateTime? to,
  });
  Future<PaymentSummary> getPaymentSummary();
  Future<List<PaymentModel>> searchPayments(String query);
}

class PaymentsDataSourceImpl implements PaymentsDataSource {
  final FirebaseFirestore _db;
  PaymentsDataSourceImpl(this._db);
  @override
  Future<List<PaymentModel>> getPayments({
    String? statusFilter,
    String? planFilter,
    DateTime? from,
    DateTime? to,
  }) async {
    final users = await _db.collection('users').get();
    final plans = await _db.collection('subscription_plans').get();
    final names = {
      for (final d in plans.docs) d.id: d.data()['name'] as String? ?? d.id,
    };
    final userMap = {for (final d in users.docs) d.id: d.data()};
    final snap = await _db.collectionGroup('payments').get();
    final payments =
        snap.docs
            .map((doc) {
              final uid = doc.reference.parent.parent?.id ?? '';
              final user = userMap[uid] ?? <String, dynamic>{};
              return PaymentModel.fromFirestore(
                doc.data(),
                doc.id,
                uid,
                username: user['username'] as String? ?? '',
                email: user['email'] as String? ?? '',
                phoneNumber: user['phoneNumber'] as String? ?? '',
                planName: resolvePlanLabel(
                  doc.data()['planId'] as String? ?? '',
                  names,
                ),
              );
            })
            .where((p) {
              if (statusFilter != null &&
                  statusFilter != 'all' &&
                  p.status != statusFilter) {
                return false;
              }
              if (planFilter != null &&
                  planFilter != 'all' &&
                  p.planId != planFilter) {
                return false;
              }
              final date = reportDate(p.createdAt);
              if (from != null &&
                  (date == null || date.isBefore(reportDay(from)))) {
                return false;
              }
              if (to != null &&
                  (date == null ||
                      !date.isBefore(
                        reportDay(to).add(const Duration(days: 1)),
                      ))) {
                return false;
              }
              return true;
            })
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return payments;
  }

  @override
  Future<PaymentSummary> getPaymentSummary() async {
    final snap = await _db.collectionGroup('payments').get();
    final now = DateTime.now().toUtc();
    final start = DateTime.utc(now.year, now.month),
        end = DateTime.utc(now.year, now.month + 1);
    final week = now.subtract(const Duration(days: 7));
    final receipts = snap.docs
        .map((d) => d.data())
        .where(isLiveRevenue)
        .toList();
    double sum(bool Function(Map<String, dynamic>) include) =>
        receipts.where(include).fold(0.0, (a, p) => a + receiptAmount(p));
    return PaymentSummary(
      totalRevenue: sum((_) => true),
      monthlyRevenue: sum((p) => inReportRange(p['createdAt'], start, end)),
      weeklyRevenue: sum(
        (p) => inReportRange(
          p['createdAt'],
          week,
          now.add(const Duration(microseconds: 1)),
        ),
      ),
      totalTransactions: receipts.length,
      successCount: receipts.length,
      failedCount: 0,
      successRate: 0,
    );
  }

  @override
  Future<List<PaymentModel>> searchPayments(String query) async {
    final q = query.trim().toLowerCase();
    return (await getPayments())
        .where(
          (p) => [
            p.reference,
            p.username,
            p.email,
            p.phoneNumber,
            p.planId,
            p.planLabel,
          ].any((s) => s.toLowerCase().contains(q)),
        )
        .toList();
  }
}
