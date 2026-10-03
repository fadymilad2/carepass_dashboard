part of '../../pages/settings_page.dart';

class _CheckLimitRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int value;
  final ValueChanged<int> onChanged;

  const _CheckLimitRow({
    required this.icon,
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DDimens.radiusMD),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: DTextStyles.label)),
        Row(
          children: [
            IconButton(
              onPressed: value > 1 ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: DColors.primary,
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(
                '$value',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: DColors.primary,
                ),
              ),
            ),
            IconButton(
              onPressed: value < 10 ? () => onChanged(value + 1) : null,
              icon: const Icon(Icons.add_circle_outline),
              color: DColors.primary,
            ),
          ],
        ),
        Text('/ month', style: DTextStyles.bodySmall),
      ],
    );
  }
}
