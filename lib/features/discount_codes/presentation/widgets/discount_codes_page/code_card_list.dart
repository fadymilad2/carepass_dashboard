part of '../../pages/discount_codes_page.dart';

class _CodeCardList extends StatelessWidget {
  final List<DiscountCodeEntity> codes;
  final Function(DiscountCodeEntity) onToggle;
  final Function(DiscountCodeEntity) onDelete;
  final Function(DiscountCodeEntity) onViewUsage;

  const _CodeCardList({
    required this.codes,
    required this.onToggle,
    required this.onDelete,
    required this.onViewUsage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: codes.map((code) {
        final statusColor = code.isExpired
            ? DColors.error
            : (code.isActive ? DColors.success : DColors.textSecondary);

        return Container(
          key: ValueKey(code.id),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DColors.surface,
            borderRadius: BorderRadius.circular(DDimens.radiusLG),
            border: Border.all(color: DColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: code + status
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: code.code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied!'),
                          duration: Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: DColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: DColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            code.code,
                            style: DTextStyles.label.copyWith(
                              color: DColors.primary,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy_outlined,
                            size: 14,
                            color: DColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ✅ توحيد Status الموبايل زي الويب بالظبط
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      code.statusDisplay,
                      style: DTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Info row
              Row(
                children: [
                  _InfoPill(
                    label: code.discountLabel,
                    color: DColors.success,
                    icon: Icons.local_offer_outlined,
                  ),
                  const SizedBox(width: 8),
                  _InfoPill(
                    label: code.usageLabel,
                    color: DColors.info,
                    icon: Icons.people_outline,
                  ),
                  if (code.isBulk) ...[
                    const SizedBox(width: 8),
                    _InfoPill(
                      label: 'Bulk',
                      color: DColors.warning,
                      icon: Icons.business_outlined,
                    ),
                  ],
                ],
              ),

              if (code.organization.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(code.organization, style: DTextStyles.bodySmall),
              ],

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Actions
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => onViewUsage(code),
                    icon: const Icon(Icons.bar_chart_outlined, size: 14),
                    label: const Text('Usage'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DColors.info,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: BorderSide(
                        color: DColors.info.withValues(alpha: 0.5),
                      ),
                      textStyle: DTextStyles.bodySmall,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: code.isActive,
                    onChanged: (_) => onToggle(code),
                  ),
                  SmallIconBtn(
                    icon: Icons.delete_outline,
                    color: DColors.error,
                    tooltip: 'Delete',
                    onTap: () => onDelete(code),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
