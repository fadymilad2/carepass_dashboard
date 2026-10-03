import 'package:dartz/dartz.dart';
import '../../domain/entities/overview_entities.dart';
import '../../domain/repositories/overview_repository.dart';
import '../datasources/overview_datasource.dart';

class OverviewRepositoryImpl implements OverviewRepository {
  final OverviewDataSource _ds;
  OverviewRepositoryImpl(this._ds);

  @override
  Future<Either<String, OverviewStats>> getStats() async {
    try {
      return Right(await _ds.getStats());
    } catch (e) {
      return Left('Failed to load stats: $e');
    }
  }

  @override
  Future<Either<String, List<RevenuePoint>>> getRevenueChart() async {
    try {
      return Right(await _ds.getRevenueChart());
    } catch (e) {
      return Left('Failed to load chart: $e');
    }
  }

  @override
  Future<Either<String, List<PlanData>>> getPlanDistribution() async {
    try {
      return Right(await _ds.getPlanDistribution());
    } catch (e) {
      return Left('Failed to load plans: $e');
    }
  }

  @override
  Future<Either<String, List<RecentTransaction>>>
  getRecentTransactions() async {
    try {
      return Right(await _ds.getRecentTransactions());
    } catch (e) {
      return Left('Failed to load transactions: $e');
    }
  }
}
