part of '../../pages/plans_page.dart';

class _PlanCard extends StatelessWidget {
  final PlanEntity plan;
  final VoidCallback onEdit, onToggle, onDelete;

  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(
          color: plan.isPopular ? DColors.primary : DColors.border,
          width: plan.isPopular ? 2 : 1,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: DColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(plan.name, style: DTextStyles.h3),
                        if (plan.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: DColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Popular',
                              style: DTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${plan.typeLabel} · ${plan.durationLabel}',
                      style: DTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: plan.isActive ? 'active' : 'inactive'),
            ],
          ),

          const Spacer(),

          Text(
            plan.priceLabel,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: DColors.primary,
            ),
          ),

          if (plan.features.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...plan.features
                .take(3)
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check,
                          size: 12,
                          color: DColors.success,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            f,
                            style: DTextStyles.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    foregroundColor: DColors.info,
                    side: BorderSide(
                      color: DColors.info.withValues(alpha: 0.5),
                    ),
                    textStyle: DTextStyles.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: onToggle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  foregroundColor: plan.isActive
                      ? DColors.warning
                      : DColors.success,
                  side: BorderSide(
                    color: plan.isActive
                        ? DColors.warning.withValues(alpha: 0.5)
                        : DColors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  plan.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  size: 16,
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  foregroundColor: DColors.error,
                  side: BorderSide(color: DColors.error.withValues(alpha: 0.5)),
                ),
                child: const Icon(Icons.delete_outline, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Plan Form Sheet
// ─────────────────────────────────────────────
