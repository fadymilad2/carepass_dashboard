import 'package:dartz/dartz.dart';
import '../entities/discount_entity.dart';

abstract class DiscountRepository {
  Future<Either<String, List<DiscountCodeEntity>>> getCodes();

  Future<Either<String, void>> createCode(DiscountCodeEntity code);

  Future<Either<String, void>> updateCode(DiscountCodeEntity code);

  Future<Either<String, void>> toggleCode(String id, bool isActive);

  Future<Either<String, void>> deleteCode(String id);

  Future<Either<String, DiscountCodeEntity?>> validateCode({
    required String code,
    required String userId,
  });
}
