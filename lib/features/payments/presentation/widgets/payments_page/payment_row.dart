part of '../../pages/payments_page.dart';

class _PaymentRow extends StatelessWidget {
  final PaymentEntity payment;
  const _PaymentRow({required this.payment});

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    try {
      dateStr = DateFormat(
        'MMM d, y',
      ).format(DateTime.parse(payment.createdAt));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              payment.reference,
              style: DTextStyles.bodySmall.copyWith(
                fontFamily: 'monospace',
                color: DColors.primary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.username.isNotEmpty ? payment.username : 'Unknown',
                  style: DTextStyles.body,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  payment.email,
                  style: DTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(payment.planLabel, style: DTextStyles.body),
          ),
          Expanded(
            flex: 1,
            child: Text(
              payment.amountLabel,
              style: DTextStyles.label.copyWith(color: DColors.success),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusBadge(status: payment.status),
                Text(payment.environmentLabel, style: DTextStyles.bodySmall),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(dateStr, style: DTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile Card List
// ─────────────────────────────────────────────
