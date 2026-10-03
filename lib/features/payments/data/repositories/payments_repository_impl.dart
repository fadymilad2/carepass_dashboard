import '../../../../core/utils/receipt_csv.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_datasource.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsDataSource _ds;
  PaymentsRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<PaymentEntity>>> getPayments({
    String? statusFilter,
    String? planFilter,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      return Right(
        await _ds.getPayments(
          statusFilter: statusFilter,
          planFilter: planFilter,
          from: from,
          to: to,
        ),
      );
    } catch (e) {
      return Left('Failed to load payments: $e');
    }
  }

  @override
  Future<Either<String, PaymentSummary>> getPaymentSummary() async {
    try {
      return Right(await _ds.getPaymentSummary());
    } catch (e) {
      return Left('Failed to load summary: $e');
    }
  }

  @override
  Future<Either<String, List<PaymentEntity>>> searchPayments(
    String query,
  ) async {
    try {
      return Right(await _ds.searchPayments(query));
    } catch (e) {
      return Left('Search failed: $e');
    }
  }

  @override
  Future<Either<String, String>> exportCsv(List<PaymentEntity> payments) async {
    try {
      return Right(receiptCsv(payments));
    } catch (e) {
      return Left('Export failed: $e');
    }
  }
}
