part of '../../pages/discount_codes_page.dart';

class _CodeRow extends StatelessWidget {
  final DiscountCodeEntity code;
  final VoidCallback onToggle, onDelete, onViewUsage;

  const _CodeRow({
    super.key,
    required this.code,
    required this.onToggle,
    required this.onDelete,
    required this.onViewUsage,
  });

  @override
  Widget build(BuildContext context) {
    String expiryStr = code.expiryDate.isEmpty ? 'No expiry' : '';
    if (code.expiryDate.isNotEmpty) {
      try {
        expiryStr = DateFormat(
          'MMM d, y',
        ).format(DateTime.parse(code.expiryDate));
      } catch (_) {}
    }

    final statusColor = code.isExpired
        ? DColors.error
        : (code.isActive ? DColors.success : DColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Code chip - ✅ غلفناها بـ Align عشان متتمطش
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
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
                    vertical: 4,
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
                      Flexible(
                        child: Text(
                          code.code,
                          style: DTextStyles.label.copyWith(
                            color: DColors.primary,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            ),
          ),

          // Discount
          Expanded(
            flex: 1,
            child: Text(
              code.discountLabel,
              style: DTextStyles.label.copyWith(color: DColors.success),
            ),
          ),

          // Organization
          Expanded(
            flex: 2,
            child: code.organization.isNotEmpty
                ? Row(
                    children: [
                      const Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: DColors.info,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          code.organization,
                          style: DTextStyles.body,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'General',
                    style: DTextStyles.body.copyWith(
                      color: DColors.textSecondary,
                    ),
                  ),
          ),

          // Usage
          Expanded(
            flex: 1,
            child: Text(code.usageLabel, style: DTextStyles.body),
          ),

          // Expiry
          Expanded(
            flex: 1,
            child: Text(
              expiryStr,
              style: DTextStyles.bodySmall.copyWith(
                color: code.isExpired ? DColors.error : DColors.textSecondary,
              ),
            ),
          ),

          // Status - ✅ وحدنا الشكل وخليناه Align centerLeft عشان ميتمطش
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  code.statusDisplay,
                  style: DTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                ActionBtn(
                  icon: Icons.bar_chart_outlined,
                  label: 'Usage',
                  color: DColors.info,
                  onTap: onViewUsage,
                ),
                const SizedBox(width: 6),
                Switch(value: code.isActive, onChanged: (_) => onToggle()),
                SmallIconBtn(
                  icon: Icons.delete_outline,
                  color: DColors.error,
                  tooltip: 'Delete',
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile Card List
// ─────────────────────────────────────────────
