part of '../../pages/payments_page.dart';

class _PaymentCardList extends StatelessWidget {
  final List<PaymentEntity> payments;
  const _PaymentCardList({required this.payments});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: payments.map((p) {
        String dateStr = '';
        try {
          dateStr = DateFormat('MMM d, y').format(DateTime.parse(p.createdAt));
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DColors.surface,
            borderRadius: BorderRadius.circular(DDimens.radiusLG),
            border: Border.all(color: DColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: p.isSuccess
                          ? DColors.successLight
                          : p.isFailed
                          ? DColors.errorLight
                          : DColors.warningLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      p.isSuccess
                          ? Icons.check
                          : p.isFailed
                          ? Icons.close
                          : Icons.hourglass_empty,
                      color: p.isSuccess
                          ? DColors.success
                          : p.isFailed
                          ? DColors.error
                          : DColors.warning,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${p.planLabel} Plan', style: DTextStyles.label),
                        Text(
                          p.reference,
                          style: DTextStyles.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: DColors.primary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        p.amountLabel,
                        style: DTextStyles.label.copyWith(
                          color: DColors.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Column(
                        children: [
                          StatusBadge(status: p.status),
                          Text(
                            p.environmentLabel,
                            style: DTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 12,
                    color: DColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      p.username.isNotEmpty ? p.username : 'Unknown',
                      style: DTextStyles.bodySmall,
                    ),
                  ),
                  Text(dateStr, style: DTextStyles.bodySmall),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
