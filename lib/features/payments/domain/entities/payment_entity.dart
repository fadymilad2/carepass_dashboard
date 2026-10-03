import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String reference;
  final String userId;
  final String username;
  final String email;
  final String planId;
  final double amount;
  final String currency;
  final String status;
  final String createdAt;
  final String? channel;
  final String environment;
  final String? planName;
  final String phoneNumber;

  const PaymentEntity({
    required this.id,
    required this.reference,
    required this.userId,
    required this.username,
    required this.email,
    required this.planId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.channel,
    this.environment = 'unknown',
    this.planName,
    this.phoneNumber = '',
  });

  bool get isSuccess => status == 'success';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';

  String get planLabel =>
      planName ?? (planId.isEmpty ? 'Unknown plan' : planId);
  String get environmentLabel => environment == 'live'
      ? 'Live'
      : environment == 'sandbox'
      ? 'Sandbox'
      : 'Unknown environment';

  String get amountLabel => '$currency ${amount.toStringAsFixed(2)}';

  String get statusLabel {
    switch (status) {
      case 'success':
        return 'Success';
      case 'failed':
        return 'Failed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  @override
  List<Object?> get props => [
    id,
    reference,
    userId,
    username,
    email,
    planId,
    amount,
    currency,
    status,
    createdAt,
    channel,
    environment,
    planName,
    phoneNumber,
  ];
}

class PaymentSummary {
  final double totalRevenue;
  final double monthlyRevenue;
  final double weeklyRevenue;
  final int totalTransactions;
  final int successCount;
  final int failedCount;
  final double successRate;

  const PaymentSummary({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.weeklyRevenue,
    required this.totalTransactions,
    required this.successCount,
    required this.failedCount,
    required this.successRate,
  });
}
