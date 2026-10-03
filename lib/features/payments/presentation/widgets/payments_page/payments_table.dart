part of '../../pages/payments_page.dart';

class _PaymentsTable extends StatelessWidget {
  final List<PaymentEntity> payments;
  const _PaymentsTable({required this.payments});

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
                Expanded(flex: 2, child: _TH('Reference')),
                Expanded(flex: 2, child: _TH('User')),
                Expanded(flex: 1, child: _TH('Plan')),
                Expanded(flex: 1, child: _TH('Amount')),
                Expanded(flex: 1, child: _TH('Status')),
                Expanded(flex: 1, child: _TH('Date')),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: payments.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) => _PaymentRow(payment: payments[i]),
          ),
        ],
      ),
    );
  }
}
