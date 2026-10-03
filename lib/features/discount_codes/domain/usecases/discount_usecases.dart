import 'package:dartz/dartz.dart';
import '../entities/discount_entity.dart';
import '../repositories/discount_repository.dart';

class GetDiscountCodes {
  final DiscountRepository repo;
  GetDiscountCodes(this.repo);
  Future<Either<String, List<DiscountCodeEntity>>> call() => repo.getCodes();
}

class CreateDiscountCode {
  final DiscountRepository repo;
  CreateDiscountCode(this.repo);
  Future<Either<String, void>> call(DiscountCodeEntity code) =>
      repo.createCode(code);
}

class UpdateDiscountCode {
  final DiscountRepository repo;
  UpdateDiscountCode(this.repo);
  Future<Either<String, void>> call(DiscountCodeEntity code) =>
      repo.updateCode(code);
}

class ToggleDiscountCode {
  final DiscountRepository repo;
  ToggleDiscountCode(this.repo);
  Future<Either<String, void>> call(String id, bool isActive) =>
      repo.toggleCode(id, isActive);
}

class DeleteDiscountCode {
  final DiscountRepository repo;
  DeleteDiscountCode(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteCode(id);
}
