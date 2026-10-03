import 'package:dartz/dartz.dart';
import '../entities/service_entity.dart';
import '../repositories/services_repository.dart';

class GetServices {
  final ServicesRepository repo;
  GetServices(this.repo);
  Future<Either<String, List<ServiceEntity>>> call({String? providerId}) =>
      repo.getServices(providerId: providerId);
}

class AddService {
  final ServicesRepository repo;
  AddService(this.repo);
  Future<Either<String, void>> call(ServiceEntity s) => repo.addService(s);
}

class UpdateService {
  final ServicesRepository repo;
  UpdateService(this.repo);
  Future<Either<String, void>> call(ServiceEntity s) => repo.updateService(s);
}

class ToggleService {
  final ServicesRepository repo;
  ToggleService(this.repo);
  Future<Either<String, void>> call(String id, bool isAvailable) =>
      repo.toggleService(id, isAvailable);
}

class DeleteService {
  final ServicesRepository repo;
  DeleteService(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteService(id);
}
