import 'package:flutter/material.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/provider_entity.dart';

class ProvidersGrid extends StatelessWidget {
  final List<ProviderEntity> providers;
  final Function(ProviderEntity) onEdit;
  final Function(ProviderEntity) onToggle;
  final Function(ProviderEntity) onDelete;

  const ProvidersGrid({
    super.key,
    required this.providers,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.isTablet(context) ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: cols == 1 ? 2.5 : 2.2,
      ),
      itemCount: providers.length,
      itemBuilder: (_, i) => _ProviderCard(
        provider: providers[i],
        onEdit: () => onEdit(providers[i]),
        onToggle: () => onToggle(providers[i]),
        onDelete: () => onDelete(providers[i]),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ProviderEntity provider;
  final VoidCallback onEdit, onToggle, onDelete;

  const _ProviderCard({
    required this.provider,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ──────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    provider.avatarLetter,
                    style: DTextStyles.label.copyWith(color: DColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: DTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${provider.typeLabel} · ${provider.area}',
                      style: DTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              StatusBadge(status: provider.isActive ? 'active' : 'inactive'),
            ],
          ),

          const Spacer(),

          // ── Info row ─────────────────────────
          Row(
            children: [
              _InfoChip(label: provider.discountLabel, color: DColors.success),
              const SizedBox(width: 6),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: DTextStyles.bodySmall,
                  ),
                ],
              ),
              if (provider.isInNetwork) ...[
                const SizedBox(width: 6),
                _InfoChip(label: 'In Network', color: DColors.info),
              ],
            ],
          ),

          const SizedBox(height: 10),

          // ── Action buttons ───────────────────
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
                  foregroundColor: provider.isActive
                      ? DColors.warning
                      : DColors.success,
                  side: BorderSide(
                    color: provider.isActive
                        ? DColors.warning.withValues(alpha: 0.5)
                        : DColors.success.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  provider.isActive
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: DTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}
