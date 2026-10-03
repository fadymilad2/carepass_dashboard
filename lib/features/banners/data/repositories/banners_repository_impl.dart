import 'package:dartz/dartz.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/repositories/banners_repository.dart';
import '../datasources/banners_datasource.dart';
import '../models/banner_model.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersDataSource _ds;
  BannersRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<BannerEntity>>> getBanners() async {
    try {
      return Right(await _ds.getBanners());
    } catch (e) {
      return Left('Failed to load banners: $e');
    }
  }

  @override
  Future<Either<String, void>> addBanner(BannerEntity b) async {
    try {
      await _ds.addBanner(b as BannerModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to add banner: $e');
    }
  }

  @override
  Future<Either<String, void>> updateBanner(BannerEntity b) async {
    try {
      await _ds.updateBanner(b as BannerModel);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update banner: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleBannerStatus(
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
  Future<Either<String, void>> deleteBanner(String id) async {
    try {
      await _ds.deleteBanner(id);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete banner: $e');
    }
  }

  @override
  Future<Either<String, void>> reorderBanners(List<String> ids) async {
    try {
      await _ds.reorderBanners(ids);
      return const Right(null);
    } catch (e) {
      return Left('Failed to reorder: $e');
    }
  }
}
