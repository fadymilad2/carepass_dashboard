import 'package:dartz/dartz.dart';
import '../entities/plan_entity.dart';

abstract class PlansRepository {
  Future<Either<String, List<PlanEntity>>> getPlans();
  Future<Either<String, void>> addPlan(PlanEntity plan);
  Future<Either<String, void>> updatePlan(PlanEntity plan);
  Future<Either<String, void>> togglePlan(String id, bool isActive);
  Future<Either<String, void>> deletePlan(String id);
}
