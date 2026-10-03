import 'package:dartz/dartz.dart';
import '../entities/banner_entity.dart';

abstract class BannersRepository {
  Future<Either<String, List<BannerEntity>>> getBanners();

  Future<Either<String, void>> addBanner(BannerEntity banner);

  Future<Either<String, void>> updateBanner(BannerEntity banner);

  Future<Either<String, void>> toggleBannerStatus(String id, bool isActive);

  Future<Either<String, void>> deleteBanner(String id);

  Future<Either<String, void>> reorderBanners(List<String> orderedIds);
}
