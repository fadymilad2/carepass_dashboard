import 'package:dartz/dartz.dart';
import '../entities/provider_entity.dart';

abstract class ProvidersRepository {
  Future<Either<String, List<ProviderEntity>>> getProviders();

  Future<Either<String, void>> addProvider(ProviderEntity provider);

  Future<Either<String, void>> updateProvider(ProviderEntity provider);

  Future<Either<String, void>> toggleProviderStatus(
    String providerId,
    bool isActive,
  );

  Future<Either<String, void>> deleteProvider(String providerId);
}
