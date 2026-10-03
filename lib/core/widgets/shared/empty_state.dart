part of '../shared_widgets.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: DColors.background,
              shape: BoxShape.circle,
              border: Border.all(color: DColors.border),
            ),
            child: Icon(icon, size: 32, color: DColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(title, style: DTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: DTextStyles.body.copyWith(color: DColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Error State ✅
// ─────────────────────────────────────────────
