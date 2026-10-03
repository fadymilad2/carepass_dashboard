part of '../../pages/users_page.dart';

class _StatusFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const _StatusFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusMD),
        border: Border.all(color: DColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: DTextStyles.body,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Status')),
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'expired', child: Text('Expired')),
            DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
            DropdownMenuItem(value: 'none', child: Text('No Plan')),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Plan Filter
// ─────────────────────────────────────────────
