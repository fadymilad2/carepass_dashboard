import 'package:dartz/dartz.dart';
import '../../domain/entities/provider_entity.dart';
import '../../domain/repositories/providers_repository.dart';
import '../datasources/providers_datasource.dart';
import '../models/provider_model.dart';

class ProvidersRepositoryImpl implements ProvidersRepository {
  final ProvidersDataSource _ds;
  ProvidersRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<ProviderEntity>>> getProviders() async {
    try {
      return Right(await _ds.getProviders());
    } catch (e) {
      return Left('Failed to load providers: $e');
    }
  }

  @override
  Future<Either<String, void>> addProvider(ProviderEntity p) async {
    try {
      await _ds.addProvider(p as ProviderModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add provider: $e');
    }
  }

  @override
  Future<Either<String, void>> updateProvider(ProviderEntity p) async {
    try {
      await _ds.updateProvider(p as ProviderModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update provider: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleProviderStatus(
    String id,
    bool isActive,
  ) async {
    try {
      await _ds.toggleStatus(id, isActive);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update status: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteProvider(String id) async {
    try {
      await _ds.deleteProvider(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete provider: $e');
    }
  }
}
