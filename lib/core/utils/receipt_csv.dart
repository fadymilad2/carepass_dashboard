import '../../features/payments/domain/entities/payment_entity.dart';

String receiptCsv(List<PaymentEntity> payments) {
  String cell(Object? value) {
    var text = value?.toString() ?? '';
    if (RegExp(r'^[\s]*[=+@-]').hasMatch(text)) text = "'$text";
    return '"${text.replaceAll('"', '""')}"';
  }

  final rows = <List<Object?>>[
    [
      'Reference',
      'User',
      'Email',
      'Phone',
      'Plan ID',
      'Plan',
      'Amount',
      'Currency',
      'Status',
      'Environment',
      'Date',
    ],
    for (final p in payments)
      [
        p.reference,
        p.username,
        p.email,
        p.phoneNumber,
        p.planId,
        p.planLabel,
        p.amount,
        p.currency,
        p.status,
        p.environment,
        p.createdAt,
      ],
  ];
  return rows.map((r) => r.map(cell).join(',')).join('\r\n');
}
