import 'package:dartz/dartz.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/repositories/discount_repository.dart';
import '../datasources/discount_datasource.dart';
import '../models/discount_model.dart';

class DiscountRepositoryImpl implements DiscountRepository {
  final DiscountDataSource _ds;
  DiscountRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<DiscountCodeEntity>>> getCodes() async {
    try {
      return Right(await _ds.getCodes());
    } catch (e) {
      return Left('Failed to load codes: $e');
    }
  }

  @override
  Future<Either<String, void>> createCode(DiscountCodeEntity code) async {
    try {
      await _ds.createCode(code as DiscountCodeModel);
      return const Right(null);
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, void>> updateCode(DiscountCodeEntity code) async {
    try {
      await _ds.updateCode(code as DiscountCodeModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleCode(String id, bool isActive) async {
    try {
      await _ds.toggleCode(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left('Failed to toggle: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteCode(String id) async {
    try {
      await _ds.deleteCode(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete: $e');
    }
  }

  @override
  Future<Either<String, DiscountCodeEntity?>> validateCode({
    required String code,
    required String userId,
  }) async {
    try {
      return Right(await _ds.validateCode(code: code, userId: userId));
    } catch (e) {
      return Left('Validation failed: $e');
    }
  }
}
