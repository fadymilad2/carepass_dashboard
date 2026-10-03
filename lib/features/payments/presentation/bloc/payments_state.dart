part of 'payments_bloc.dart';

abstract class PaymentsState extends Equatable {
  const PaymentsState();
  @override
  List<Object?> get props => [];
}

class PaymentsInitial extends PaymentsState {}

class PaymentsLoading extends PaymentsState {}

class PaymentsLoaded extends PaymentsState {
  final List<PaymentEntity> payments;
  final List<PaymentEntity> filtered;
  final PaymentSummary? summary;
  final String searchQuery;
  final String? statusFilter;
  final String? planFilter;
  final DateTime? from;
  final DateTime? to;

  const PaymentsLoaded({
    required this.payments,
    required this.filtered,
    this.summary,
    this.searchQuery = '',
    this.statusFilter,
    this.planFilter,
    this.from,
    this.to,
  });

  @override
  List<Object?> get props => [
    payments,
    filtered,
    summary,
    searchQuery,
    statusFilter,
    planFilter,
    from,
    to,
  ];
}

class PaymentsError extends PaymentsState {
  final String message;
  const PaymentsError(this.message);
  @override
  List<Object?> get props => [message];
}

class PaymentsExportReady extends PaymentsState {
  final String csvContent;
  const PaymentsExportReady(this.csvContent);
  @override
  List<Object?> get props => [csvContent];
}

// ── BLoC ───────────────────────────────────────────────────────────────
