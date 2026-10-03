class OverviewStats {
  final int totalUsers;
  final int activeMembers;
  final int totalProviders;
  final double monthlyRevenue;
  final int newUsersThisMonth;
  final double revenueGrowth;

  const OverviewStats({
    required this.totalUsers,
    required this.activeMembers,
    required this.totalProviders,
    required this.monthlyRevenue,
    required this.newUsersThisMonth,
    required this.revenueGrowth,
  });

  double get activeMembersPercent =>
      totalUsers > 0 ? (activeMembers / totalUsers * 100) : 0;
}

class RevenuePoint {
  final String month;
  final double amount;
  const RevenuePoint({required this.month, required this.amount});
}

class PlanData {
  final String plan;
  final int count;
  final double percent;
  const PlanData({
    required this.plan,
    required this.count,
    required this.percent,
  });
}

class RecentTransaction {
  final String reference;
  final String planId;
  final double amount;
  final String currency;
  final String status;
  final String date;
  final String userId;

  const RecentTransaction({
    required this.reference,
    required this.planId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.date,
    required this.userId,
  });
}

class OverviewData {
  final OverviewStats stats;
  final List<RevenuePoint> revenueChart;
  final List<PlanData> planDistribution;
  final List<RecentTransaction> recentTransactions;

  const OverviewData({
    required this.stats,
    required this.revenueChart,
    required this.planDistribution,
    required this.recentTransactions,
  });
}
