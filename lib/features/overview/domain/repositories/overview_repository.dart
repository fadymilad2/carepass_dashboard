import 'package:carepass_dashboard/features/overview/domain/entities/overview_entities.dart';
import 'package:dartz/dartz.dart';

abstract class OverviewRepository {
  Future<Either<String, OverviewStats>> getStats();
  Future<Either<String, List<RevenuePoint>>> getRevenueChart();
  Future<Either<String, List<PlanData>>> getPlanDistribution();
  Future<Either<String, List<RecentTransaction>>> getRecentTransactions();
}
