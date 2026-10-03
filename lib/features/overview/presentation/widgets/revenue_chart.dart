import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/overview_entities.dart';

class RevenueChart extends StatelessWidget {
  final List<RevenuePoint> data;
  const RevenueChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    if (data.isEmpty || data.every((e) => e.amount == 0)) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: 40,
                color: DColors.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'No revenue data yet',
                style: TextStyle(color: DColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final maxY = data.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: isMobile ? 180 : 220,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.25,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, _, rod, _) => BarTooltipItem(
                'GHS ${rod.toY.toStringAsFixed(0)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[idx].month,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !isMobile,
                reservedSize: 56,
                getTitlesWidget: (v, _) => Text(
                  'GHS ${v.toInt()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: DColors.textSecondary,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 100,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: DColors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.amount,
                      color: DColors.primary,
                      width: isMobile ? 18 : 26,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY * 1.25,
                        color: DColors.background,
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
