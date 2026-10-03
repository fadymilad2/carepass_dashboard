import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../bloc/overview_bloc.dart';
import '../widgets/revenue_chart.dart';
import '../widgets/plan_pie_chart.dart';
import '../widgets/recent_tx_table.dart';

part '../widgets/overview_page/stats_grid.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  void initState() {
    super.initState();
    context.read<OverviewBloc>().add(OverviewLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.padding(context);

    return BlocBuilder<OverviewBloc, OverviewState>(
      builder: (context, state) {
        final loading = state is OverviewLoading;
        final data = state is OverviewLoaded ? state.data : null;

        if (state is OverviewError) {
          return Padding(
            padding: EdgeInsets.all(padding),
            child: ErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<OverviewBloc>().add(OverviewLoadRequested()),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dashboard Overview', style: DTextStyles.h2),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d y').format(DateTime.now()),
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  ElevatedButton.icon(
                    onPressed: loading
                        ? null
                        : () => context.read<OverviewBloc>().add(
                            OverviewLoadRequested(),
                          ),
                    icon: loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Refresh'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 16 : 24),

              // ── Stat Cards ───────────────────────
              _StatsGrid(loading: loading, stats: data?.stats),

              SizedBox(height: isMobile ? 16 : 20),

              // ── Charts ───────────────────────────
              if (isMobile || isTablet)
                Column(
                  children: [
                    SectionCard(
                      title: 'Live GHS Revenue — Last 6 Months',
                      child: loading
                          ? const ShimmerBox(height: 200)
                          : RevenueChart(data: data?.revenueChart ?? []),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    SectionCard(
                      title: 'Plan Distribution',
                      child: loading
                          ? const ShimmerBox(height: 200)
                          : PlanPieChart(data: data?.planDistribution ?? []),
                    ),
                  ],
                )
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SectionCard(
                          title: 'Live GHS Revenue — Last 6 Months',
                          child: loading
                              ? const ShimmerBox(height: 220)
                              : RevenueChart(data: data?.revenueChart ?? []),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: SectionCard(
                          title: 'Plan Distribution',
                          child: loading
                              ? const ShimmerBox(height: 220)
                              : PlanPieChart(
                                  data: data?.planDistribution ?? [],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Recent Transactions ──────────────
              SectionCard(
                title: 'Recent Transactions',
                child: loading
                    ? const ShimmerBox(height: 200)
                    : RecentTxWidget(
                        transactions: data?.recentTransactions ?? [],
                      ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Stats Grid
// ─────────────────────────────────────────────
