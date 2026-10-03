part of '../../pages/overview_page.dart';

class _StatsGrid extends StatelessWidget {
  final bool loading;
  final dynamic stats;

  const _StatsGrid({required this.loading, this.stats});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    final cards = [
      (
        title: 'Total Users',
        value: loading ? '—' : '${stats?.totalUsers ?? 0}',
        subtitle: loading ? '' : '+${stats?.newUsersThisMonth ?? 0} this month',
        icon: Icons.people_outlined,
        color: DColors.primary,
      ),
      (
        title: 'Active Members',
        value: loading ? '—' : '${stats?.activeMembers ?? 0}',
        subtitle: loading
            ? ''
            : '${(stats?.activeMembersPercent ?? 0).toStringAsFixed(0)}% of users',
        icon: Icons.card_membership_outlined,
        color: DColors.success,
      ),
      (
        title: 'Monthly Revenue (Live GHS)',
        value: loading
            ? '—'
            : 'GHS ${NumberFormat('#,##0').format(stats?.monthlyRevenue ?? 0)}',
        subtitle: loading
            ? ''
            : '${(stats?.revenueGrowth ?? 0) >= 0 ? '+' : ''}${(stats?.revenueGrowth ?? 0).toStringAsFixed(1)}% vs last month',
        icon: Icons.payments_outlined,
        color: DColors.info,
      ),
      (
        title: 'Active Providers',
        value: loading ? '—' : '${stats?.totalProviders ?? 0}',
        subtitle: 'In network',
        icon: Icons.local_hospital_outlined,
        color: DColors.warning,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isMobile ? 1.3 : 1.5,
      children: cards
          .map(
            (c) => DStatCard(
              title: c.title,
              value: c.value,
              subtitle: c.subtitle,
              icon: c.icon,
              color: c.color,
              isLoading: loading,
            ),
          )
          .toList(),
    );
  }
}
