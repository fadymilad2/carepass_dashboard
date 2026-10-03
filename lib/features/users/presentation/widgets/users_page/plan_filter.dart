part of '../../pages/users_page.dart';

class _PlanFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _PlanFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('subscription_plans')
          .snapshots(),
      builder: (context, snap) {
        final plans = <DropdownMenuItem<String>>[
          const DropdownMenuItem(value: 'all', child: Text('All Plans')),
        ];

        if (snap.hasData) {
          final seen = <String>{'all'};
          for (final doc in snap.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] as String? ?? doc.id;
            if (!seen.add(name.toLowerCase())) continue;
            plans.add(
              DropdownMenuItem(value: name.toLowerCase(), child: Text(name)),
            );
          }
        }

        final validValue = plans.any((p) => p.value == value) ? value : 'all';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: DColors.surface,
            borderRadius: BorderRadius.circular(DDimens.radiusMD),
            border: Border.all(color: DColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: validValue,
              onChanged: onChanged,
              style: DTextStyles.body,
              items: plans,
            ),
          ),
        );
      },
    );
  }
}
