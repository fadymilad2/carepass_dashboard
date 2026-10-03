import 'package:dartz/dartz.dart';
import '../entities/service_entity.dart';

abstract class ServicesRepository {
  Future<Either<String, List<ServiceEntity>>> getServices({String? providerId});

  Future<Either<String, void>> addService(ServiceEntity service);

  Future<Either<String, void>> updateService(ServiceEntity service);

  Future<Either<String, void>> toggleService(String id, bool isAvailable);

  Future<Either<String, void>> deleteService(String id);
}
