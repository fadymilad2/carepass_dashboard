import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:carepass_dashboard/features/overview/presentation/widgets/plan_pie_chart.dart';
import 'package:carepass_dashboard/features/overview/domain/entities/overview_entities.dart';

void main() {
  testWidgets('plan distribution renders names from actual plans', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PlanPieChart(
            data: [PlanData(plan: 'Family Care', count: 2, percent: 100)],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Family Care (2)'), findsOneWidget);
    expect(find.text('Standard'), findsNothing);
  });
}
