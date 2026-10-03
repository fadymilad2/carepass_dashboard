import 'package:dartz/dartz.dart';
import '../entities/overview_entities.dart';
import '../repositories/overview_repository.dart';

class GetOverviewData {
  final OverviewRepository repo;
  GetOverviewData(this.repo);

  Future<Either<String, OverviewData>> call() async {
    // 1. نشغل كل الطلبات مع بعض في نفس الوقت (عشان نحافظ على الأداء السريع)
    final statsFuture = repo.getStats();
    final revenueFuture = repo.getRevenueChart();
    final planFuture = repo.getPlanDistribution();
    final txFuture = repo.getRecentTransactions();

    // 2. نستقبل النتايج (هنا فلاتر عارف نوع كل نتيجة بالمللي)
    final statsResult = await statsFuture;
    final revenueResult = await revenueFuture;
    final planResult = await planFuture;
    final txResult = await txFuture;

    // 3. بنستخدم fold عشان الكود يكون Clean ونتجنب أي Casting
    if (revenueResult.isLeft()) {
      return Left(revenueResult.fold((e) => e, (_) => ''));
    }
    if (planResult.isLeft()) return Left(planResult.fold((e) => e, (_) => ''));
    if (txResult.isLeft()) return Left(txResult.fold((e) => e, (_) => ''));
    return statsResult.fold(
      (error) => Left(error), // لو الـ Stats فشلت، بنرجع الإيرور
      (stats) => Right(
        OverviewData(
          stats: stats,
          // الـ getOrElse هنا بقت فاهمة نوع اللستة تلقائياً ومش هتضرب إيرور في الويب
          revenueChart: revenueResult.getOrElse(() => []),
          planDistribution: planResult.getOrElse(() => []),
          recentTransactions: txResult.getOrElse(() => []),
        ),
      ),
    );
  }
}
