import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/overview_entities.dart';

class PlanPieChart extends StatefulWidget {
  final List<PlanData> data;
  const PlanPieChart({super.key, required this.data});

  @override
  State<PlanPieChart> createState() => _PlanPieChartState();
}

class _PlanPieChartState extends State<PlanPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final total = widget.data.fold(0, (s, e) => s + e.count);

    if (total == 0) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pie_chart_outline,
                size: 40,
                color: DColors.textSecondary,
              ),
              SizedBox(height: 8),
              Text(
                'No subscribers yet',
                style: TextStyle(color: DColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final pie = PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 36,
        pieTouchData: PieTouchData(
          touchCallback: (_, response) => setState(() {
            _touched = response?.touchedSection?.touchedSectionIndex ?? -1;
          }),
        ),
        sections: widget.data.asMap().entries.map((e) {
          final isTouched = e.key == _touched;
          final color = DColors.chartColors[e.key % DColors.chartColors.length];
          return PieChartSectionData(
            value: e.value.count.toDouble(),
            title: '${e.value.percent.toStringAsFixed(0)}%',
            radius: isTouched ? 58 : 48,
            color: color,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          );
        }).toList(),
      ),
    );

    final legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.data.asMap().entries.map((e) {
        final color = DColors.chartColors[e.key % DColors.chartColors.length];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '${e.value.plan} (${e.value.count})',
                style: const TextStyle(
                  fontSize: 12,
                  color: DColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    return SizedBox(
      height: 220,
      child: isMobile
          ? Column(
              children: [
                Expanded(child: pie),
                const SizedBox(height: 8),
                legend,
              ],
            )
          : Row(
              children: [
                Expanded(child: pie),
                const SizedBox(width: 12),
                legend,
              ],
            ),
    );
  }
}
