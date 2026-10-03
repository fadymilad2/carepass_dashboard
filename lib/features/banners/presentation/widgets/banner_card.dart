import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/banner_entity.dart';

class BannerCard extends StatelessWidget {
  final BannerEntity banner;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const BannerCard({
    super.key,
    required this.banner,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(
          color: banner.isActive
              ? DColors.primary.withValues(alpha: 0.3)
              : DColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image preview ──────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(DDimens.radiusLG),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  banner.imageUrl.isNotEmpty
                      ? banner.imageUrl.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: banner.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const _GradientBg(),
                                errorWidget: (_, _, _) => const _GradientBg(),
                              )
                            : const _GradientBg()
                      : const _GradientBg(),

                  // Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),

                  // Active/Inactive badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StatusBadge(
                      status: banner.isActive ? 'active' : 'inactive',
                    ),
                  ),

                  // Type badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        banner.typeLabel,
                        style: DTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Title overlay
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (banner.discountPercent != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: DColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Up to ${banner.discountPercent}% off',
                              style: DTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        Text(
                          banner.title,
                          style: DTextStyles.label.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          banner.subtitle,
                          style: DTextStyles.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Footer ────────────────────────────
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Areas
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: DColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        banner.areasLabel,
                        style: DTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
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
                          vertical: 4,
                          horizontal: 8,
                        ),
                        foregroundColor: banner.isActive
                            ? DColors.warning
                            : DColors.success,
                        side: BorderSide(
                          color: banner.isActive
                              ? DColors.warning.withValues(alpha: 0.5)
                              : DColors.success.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(
                        banner.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        foregroundColor: DColors.error,
                        side: BorderSide(
                          color: DColors.error.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(Icons.delete_outline, size: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientBg extends StatelessWidget {
  const _GradientBg();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: DColors.cardGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Colors.white54),
      ),
    );
  }
}
