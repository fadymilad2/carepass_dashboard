part of '../../pages/payments_page.dart';

class _DropFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final List<DropdownMenuItem<String>> items;

  const _DropFilter({
    required this.value,
    required this.onChanged,
    required this.items,
  });

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
          items: items,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Desktop Table
// ─────────────────────────────────────────────
