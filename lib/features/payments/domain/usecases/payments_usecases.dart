import 'package:dartz/dartz.dart';
import '../entities/payment_entity.dart';
import '../repositories/payments_repository.dart';

class GetPayments {
  final PaymentsRepository repo;
  GetPayments(this.repo);

  Future<Either<String, List<PaymentEntity>>> call({
    String? statusFilter,
    String? planFilter,
    DateTime? from,
    DateTime? to,
  }) => repo.getPayments(
    statusFilter: statusFilter,
    planFilter: planFilter,
    from: from,
    to: to,
  );
}

class GetPaymentSummary {
  final PaymentsRepository repo;
  GetPaymentSummary(this.repo);
  Future<Either<String, PaymentSummary>> call() => repo.getPaymentSummary();
}

class SearchPayments {
  final PaymentsRepository repo;
  SearchPayments(this.repo);
  Future<Either<String, List<PaymentEntity>>> call(String query) =>
      repo.searchPayments(query);
}

class ExportPaymentsCsv {
  final PaymentsRepository repo;
  ExportPaymentsCsv(this.repo);
  Future<Either<String, String>> call(List<PaymentEntity> payments) =>
      repo.exportCsv(payments);
}
