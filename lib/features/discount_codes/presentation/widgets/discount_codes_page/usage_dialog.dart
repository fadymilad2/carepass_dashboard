part of '../../pages/discount_codes_page.dart';

class _UsageDialog extends StatelessWidget {
  final DiscountCodeEntity code;
  const _UsageDialog({required this.code});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 460,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Usage: ${code.code}', style: DTextStyles.h3),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                  child: MiniStatChip(
                    label: 'Used',
                    value: '${code.usedCount}',
                    color: DColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MiniStatChip(
                    label: code.isUnlimited ? 'Limit' : 'Remaining',
                    value: code.isUnlimited ? '∞' : '${code.remaining}',
                    color: DColors.success,
                  ),
                ),
              ],
            ),

            if (code.organization.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DColors.infoLight,
                  borderRadius: BorderRadius.circular(DDimens.radiusMD),
                  border: Border.all(
                    color: DColors.info.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.business_outlined,
                      color: DColors.info,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Organization: ${code.organization}',
                        style: DTextStyles.label.copyWith(color: DColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Users list
            Text(
              'Used by ${code.usedByUserIds.length} users',
              style: DTextStyles.label,
            ),
            const SizedBox(height: 8),

            if (code.usedByUserIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DColors.background,
                  borderRadius: BorderRadius.circular(DDimens.radiusMD),
                ),
                child: const Center(child: Text('No usage yet')),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: DColors.background,
                  borderRadius: BorderRadius.circular(DDimens.radiusMD),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: code.usedByUserIds.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      code.usedByUserIds[i],
                      style: DTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: DColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Create Code Sheet
// ─────────────────────────────────────────────
