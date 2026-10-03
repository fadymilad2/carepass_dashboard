import 'package:dartz/dartz.dart';
import '../../domain/entities/plan_entity.dart';
import '../../domain/repositories/plans_repository.dart';
import '../datasources/plans_datasource.dart';
import '../models/plan_model.dart';

class PlansRepositoryImpl implements PlansRepository {
  final PlansDataSource _ds;
  PlansRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<PlanEntity>>> getPlans() async {
    try {
      return Right(await _ds.getPlans());
    } catch (e) {
      return Left('Failed to load plans: $e');
    }
  }

  @override
  Future<Either<String, void>> addPlan(PlanEntity p) async {
    try {
      await _ds.addPlan(p as PlanModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add plan: $e');
    }
  }

  @override
  Future<Either<String, void>> updatePlan(PlanEntity p) async {
    try {
      await _ds.updatePlan(p as PlanModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update plan: $e');
    }
  }

  @override
  Future<Either<String, void>> togglePlan(String id, bool isActive) async {
    try {
      await _ds.togglePlan(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left('Failed to toggle plan: $e');
    }
  }

  @override
  Future<Either<String, void>> deletePlan(String id) async {
    try {
      await _ds.deletePlan(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete plan: $e');
    }
  }
}
