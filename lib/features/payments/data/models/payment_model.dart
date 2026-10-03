import '../../../../core/utils/reporting.dart';
import '../../domain/entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({
    required super.id,
    required super.reference,
    required super.userId,
    required super.username,
    required super.email,
    required super.planId,
    required super.amount,
    required super.currency,
    required super.status,
    required super.createdAt,
    super.channel,
    super.environment,
    super.planName,
    super.phoneNumber,
  });

  factory PaymentModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
    String userId, {
    String username = '',
    String email = '',
    String phoneNumber = '',
    String? planName,
  }) {
    return PaymentModel(
      id: id,
      environment: data['environment'] as String? ?? 'unknown',
      planName: planName,
      phoneNumber: phoneNumber,
      reference: data['reference'] ?? '—',
      userId: userId,
      username: username,
      email: email,
      planId: data['planId'] ?? '',
      amount: receiptAmount(data),
      currency: data['currency'] ?? 'GHS',
      status: data['status'] ?? 'pending',
      createdAt: reportDateString(data['createdAt']),
      channel: data['channel'],
    );
  }
}
