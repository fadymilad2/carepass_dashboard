import 'package:dartz/dartz.dart';
import '../entities/payment_entity.dart';

abstract class PaymentsRepository {
  Future<Either<String, List<PaymentEntity>>> getPayments({
    String? statusFilter,
    String? planFilter,
    DateTime? from,
    DateTime? to,
  });

  Future<Either<String, PaymentSummary>> getPaymentSummary();

  Future<Either<String, List<PaymentEntity>>> searchPayments(String query);

  Future<Either<String, String>> exportCsv(List<PaymentEntity> payments);
}
