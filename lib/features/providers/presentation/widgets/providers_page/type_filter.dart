part of '../../pages/providers_page.dart';

class _TypeFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _TypeFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('provider_types')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .snapshots(),
      builder: (context, snap) {
        final types = <Map<String, String>>[
          {'value': 'all', 'label': 'All Types'},
        ];

        if (snap.hasData && snap.data!.docs.isNotEmpty) {
          types.addAll(
            snap.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'value': data['value'] as String? ?? doc.id,
                'label': data['name'] as String? ?? doc.id,
              };
            }),
          );
        } else {
          // ✅ Static fallback
          types.addAll([
            {'value': 'clinic', 'label': 'Clinic'},
            {'value': 'hospital', 'label': 'Hospital'},
            {'value': 'pharmacy', 'label': 'Pharmacy'},
            {'value': 'lab', 'label': 'Laboratory'},
            {'value': 'dental', 'label': 'Dental'},
            {'value': 'eye_clinic', 'label': 'Eye Clinic'},
            {'value': 'diagnostic', 'label': 'Diagnostic Center'},
            {'value': 'doctor', 'label': 'Doctor'},
          ]);
        }

        final validValue = types.any((t) => t['value'] == value)
            ? value
            : 'all';

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
              items: types
                  .map(
                    (t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Status Filter
// ─────────────────────────────────────────────
