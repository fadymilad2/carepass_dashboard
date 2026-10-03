import 'package:dartz/dartz.dart';
import '../entities/provider_entity.dart';
import '../repositories/providers_repository.dart';

class GetProviders {
  final ProvidersRepository repo;
  GetProviders(this.repo);
  Future<Either<String, List<ProviderEntity>>> call() => repo.getProviders();
}

class AddProvider {
  final ProvidersRepository repo;
  AddProvider(this.repo);
  Future<Either<String, void>> call(ProviderEntity p) => repo.addProvider(p);
}

class UpdateProvider {
  final ProvidersRepository repo;
  UpdateProvider(this.repo);
  Future<Either<String, void>> call(ProviderEntity p) => repo.updateProvider(p);
}

class ToggleProviderStatus {
  final ProvidersRepository repo;
  ToggleProviderStatus(this.repo);
  Future<Either<String, void>> call(String id, bool isActive) =>
      repo.toggleProviderStatus(id, isActive);
}

class DeleteProvider {
  final ProvidersRepository repo;
  DeleteProvider(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteProvider(id);
}
