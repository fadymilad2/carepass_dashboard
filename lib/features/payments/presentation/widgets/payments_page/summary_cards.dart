part of '../../pages/payments_page.dart';

class _SummaryCards extends StatelessWidget {
  final PaymentSummary summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final fmt = NumberFormat('#,##0.00');

    final cards = [
      (
        title: 'Total Live Revenue',
        value: 'GHS ${fmt.format(summary.totalRevenue)}',
        subtitle: 'All time',
        icon: Icons.account_balance_wallet_outlined,
        color: DColors.primary,
      ),
      (
        title: 'Monthly Live Revenue',
        value: 'GHS ${fmt.format(summary.monthlyRevenue)}',
        subtitle: 'This month',
        icon: Icons.calendar_month_outlined,
        color: DColors.success,
      ),
      (
        title: 'Weekly Live Revenue',
        value: 'GHS ${fmt.format(summary.weeklyRevenue)}',
        subtitle: 'Last 7 days',
        icon: Icons.trending_up_outlined,
        color: DColors.info,
      ),
      (
        title: 'Live GHS Receipts',
        value: '${summary.successCount}',
        subtitle: 'Confirmed receipts, not payment attempts',
        icon: Icons.check_circle_outline,
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
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  Filters Row
// ─────────────────────────────────────────────
