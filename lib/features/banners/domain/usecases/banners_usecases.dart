import 'package:dartz/dartz.dart';
import '../entities/banner_entity.dart';
import '../repositories/banners_repository.dart';

class GetBanners {
  final BannersRepository repo;
  GetBanners(this.repo);
  Future<Either<String, List<BannerEntity>>> call() => repo.getBanners();
}

class AddBanner {
  final BannersRepository repo;
  AddBanner(this.repo);
  Future<Either<String, void>> call(BannerEntity b) => repo.addBanner(b);
}

class UpdateBanner {
  final BannersRepository repo;
  UpdateBanner(this.repo);
  Future<Either<String, void>> call(BannerEntity b) => repo.updateBanner(b);
}

class ToggleBannerStatus {
  final BannersRepository repo;
  ToggleBannerStatus(this.repo);
  Future<Either<String, void>> call(String id, bool isActive) =>
      repo.toggleBannerStatus(id, isActive);
}

class DeleteBanner {
  final BannersRepository repo;
  DeleteBanner(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteBanner(id);
}

class ReorderBanners {
  final BannersRepository repo;
  ReorderBanners(this.repo);
  Future<Either<String, void>> call(List<String> ids) =>
      repo.reorderBanners(ids);
}
