part of '../../pages/payments_page.dart';

class _FiltersRow extends StatelessWidget {
  final Map<String, String> plans;
  final TextEditingController searchCtrl;
  final String statusFilter;
  final String planFilter;
  final DateTime? from;
  final DateTime? to;
  final bool isMobile;
  final ValueChanged<String> onSearch;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPlanChanged;
  final Function(DateTime?, DateTime?) onDateRange;

  const _FiltersRow({
    required this.plans,
    required this.searchCtrl,
    required this.statusFilter,
    required this.planFilter,
    required this.from,
    required this.to,
    required this.isMobile,
    required this.onSearch,
    required this.onStatusChanged,
    required this.onPlanChanged,
    required this.onDateRange,
  });

  @override
  Widget build(BuildContext context) {
    final searchField = TextField(
      controller: searchCtrl,
      onChanged: onSearch,
      decoration: const InputDecoration(
        hintText: 'Search by reference, user, plan...',
        prefixIcon: Icon(Icons.search, size: 18, color: DColors.textSecondary),
      ),
    );

    final statusDrop = _DropFilter(
      value: statusFilter,
      onChanged: onStatusChanged,
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Status')),
        DropdownMenuItem(value: 'success', child: Text('Success')),
        DropdownMenuItem(value: 'failed', child: Text('Failed')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
      ],
    );

    final planDrop = _DropFilter(
      value: planFilter,
      onChanged: onPlanChanged,
      items: [
        const DropdownMenuItem(value: 'all', child: Text('All Plans')),
        for (final entry in plans.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        if (planFilter != 'all' && !plans.containsKey(planFilter))
          DropdownMenuItem(value: planFilter, child: Text('Selected plan')),
      ],
    );

    final dateBtn = OutlinedButton.icon(
      onPressed: () async {
        final range = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2024),
          lastDate: DateTime.now(),
          initialDateRange: from != null && to != null
              ? DateTimeRange(start: from!, end: to!)
              : null,
          builder: (ctx, child) => Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: const ColorScheme.light(primary: DColors.primary),
            ),
            child: child!,
          ),
        );
        if (range != null) {
          onDateRange(range.start, range.end);
        } else {
          onDateRange(null, null);
        }
      },
      icon: const Icon(Icons.date_range_outlined, size: 16),
      label: Text(
        from != null && to != null
            ? '${DateFormat('MMM d').format(from!)} - ${DateFormat('MMM d').format(to!)}'
            : 'Date Range',
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: from != null ? DColors.primary : DColors.textSecondary,
        side: BorderSide(
          color: from != null ? DColors.primary : DColors.border,
        ),
      ),
    );

    if (isMobile) {
      return Column(
        children: [
          searchField,
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: statusDrop),
              const SizedBox(width: 8),
              Expanded(child: planDrop),
            ],
          ),
          const SizedBox(height: 8),
          dateBtn,
        ],
      );
    }

    return Row(
      children: [
        Expanded(flex: 3, child: searchField),
        const SizedBox(width: 12),
        statusDrop,
        const SizedBox(width: 8),
        planDrop,
        const SizedBox(width: 8),
        dateBtn,
      ],
    );
  }
}
