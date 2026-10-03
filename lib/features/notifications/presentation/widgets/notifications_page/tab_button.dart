part of '../../pages/notifications_page.dart';

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? DColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(DDimens.radiusMD - 2),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: DTextStyles.body.copyWith(
            color: selected ? Colors.white : DColors.textSecondary,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Compose Panel (unchanged — same bloc calls)
// ─────────────────────────────────────────────
