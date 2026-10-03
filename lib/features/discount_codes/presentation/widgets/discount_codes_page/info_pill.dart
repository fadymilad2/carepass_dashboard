part of '../../pages/discount_codes_page.dart';

class _InfoPill extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _InfoPill({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: DTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Usage Dialog
// ─────────────────────────────────────────────
