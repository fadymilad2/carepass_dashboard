part of '../../pages/discount_codes_page.dart';

class _CodeTable extends StatelessWidget {
  final List<DiscountCodeEntity> codes;
  final Function(DiscountCodeEntity) onToggle;
  final Function(DiscountCodeEntity) onDelete;
  final Function(DiscountCodeEntity) onViewUsage;

  const _CodeTable({
    required this.codes,
    required this.onToggle,
    required this.onDelete,
    required this.onViewUsage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: DColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(DDimens.radiusLG),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: _TH('Code')),
                Expanded(flex: 1, child: _TH('Discount')),
                Expanded(flex: 2, child: _TH('Organization')),
                Expanded(flex: 1, child: _TH('Usage')),
                Expanded(flex: 1, child: _TH('Expiry')),
                Expanded(flex: 1, child: _TH('Status')),
                Expanded(flex: 2, child: _TH('Actions')),
              ],
            ),
          ),
          const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: codes.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) {
              final code = codes[i];
              return _CodeRow(
                key: ValueKey(code.id),
                code: code,
                onToggle: () => onToggle(code),
                onDelete: () => onDelete(code),
                onViewUsage: () => onViewUsage(code),
              );
            },
          ),
        ],
      ),
    );
  }
}
