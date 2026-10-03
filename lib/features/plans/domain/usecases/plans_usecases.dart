import 'package:dartz/dartz.dart';
import '../entities/plan_entity.dart';
import '../repositories/plans_repository.dart';

class GetPlansAdmin {
  final PlansRepository repo;
  GetPlansAdmin(this.repo);
  Future<Either<String, List<PlanEntity>>> call() => repo.getPlans();
}

class AddPlan {
  final PlansRepository repo;
  AddPlan(this.repo);
  Future<Either<String, void>> call(PlanEntity p) => repo.addPlan(p);
}

class UpdatePlan {
  final PlansRepository repo;
  UpdatePlan(this.repo);
  Future<Either<String, void>> call(PlanEntity p) => repo.updatePlan(p);
}

class TogglePlan {
  final PlansRepository repo;
  TogglePlan(this.repo);
  Future<Either<String, void>> call(String id, bool isActive) =>
      repo.togglePlan(id, isActive);
}

class DeletePlan {
  final PlansRepository repo;
  DeletePlan(this.repo);
  Future<Either<String, void>> call(String id) => repo.deletePlan(id);
}
