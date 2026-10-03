import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plan_model.dart';

abstract class PlansDataSource {
  Future<List<PlanModel>> getPlans();
  Future<void> addPlan(PlanModel plan);
  Future<void> updatePlan(PlanModel plan);
  Future<void> togglePlan(String id, bool isActive);
  Future<void> deletePlan(String id);
}

class PlansDataSourceImpl implements PlansDataSource {
  final FirebaseFirestore _db;
  PlansDataSourceImpl(this._db);

  @override
  Future<List<PlanModel>> getPlans() async {
    final snap = await _db.collection('subscription_plans').get();

    return snap.docs
        .map((doc) => PlanModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<void> addPlan(PlanModel plan) async {
    _validate(plan);
    // Get max order
    final snap = await _db
        .collection('subscription_plans')
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    final maxOrder = snap.docs.isEmpty
        ? 0
        : (snap.docs.first.data()['order'] ?? 0) + 1;

    await _db
        .collection('subscription_plans')
        .doc(plan.id)
        .set(plan.copyWithFields(order: maxOrder).toFirestore());
  }

  @override
  Future<void> updatePlan(PlanModel plan) async {
    _validate(plan);
    await _db
        .collection('subscription_plans')
        .doc(plan.id)
        .update(plan.toFirestore());
  }

  @override
  Future<void> togglePlan(String id, bool isActive) async {
    await _db.collection('subscription_plans').doc(id).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> deletePlan(String id) async {
    await _db.collection('subscription_plans').doc(id).delete();
  }

  void _validate(PlanModel plan) {
    if (plan.name.trim().isEmpty ||
        !plan.price.isFinite ||
        plan.price < 0 ||
        plan.durationDays <= 0) {
      throw ArgumentError(
        'Plan requires a name, a non-negative price and a positive duration.',
      );
    }
  }
}
