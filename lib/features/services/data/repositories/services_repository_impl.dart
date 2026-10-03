import 'package:dartz/dartz.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/services_repository.dart';
import '../datasources/services_datasource.dart';
import '../models/service_model.dart';

class ServicesRepositoryImpl implements ServicesRepository {
  final ServicesDataSource _ds;
  ServicesRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<ServiceEntity>>> getServices({
    String? providerId,
  }) async {
    try {
      return Right(await _ds.getServices(providerId: providerId));
    } catch (e) {
      return Left('Failed to load services: $e');
    }
  }

  @override
  Future<Either<String, void>> addService(ServiceEntity s) async {
    try {
      await _ds.addService(s as ServiceModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add service: $e');
    }
  }

  @override
  Future<Either<String, void>> updateService(ServiceEntity s) async {
    try {
      await _ds.updateService(s as ServiceModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update service: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleService(
    String id,
    bool isAvailable,
  ) async {
    try {
      await _ds.toggleService(id, isAvailable);
      return const Right(null);
    } catch (e) {
      return Left('Failed to toggle service: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteService(String id) async {
    try {
      await _ds.deleteService(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete service: $e');
    }
  }
}
