part of 'payments_bloc.dart';

abstract class PaymentsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentsLoadRequested extends PaymentsEvent {
  final String? statusFilter;
  final String? planFilter;
  final DateTime? from;
  final DateTime? to;

  PaymentsLoadRequested({
    this.statusFilter,
    this.planFilter,
    this.from,
    this.to,
  });
}

class PaymentsSearchChanged extends PaymentsEvent {
  final String query;
  PaymentsSearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class PaymentsFilterApplied extends PaymentsEvent {
  final String? statusFilter;
  final String? planFilter;
  final DateTime? from;
  final DateTime? to;

  PaymentsFilterApplied({
    this.statusFilter,
    this.planFilter,
    this.from,
    this.to,
  });
}

class PaymentsExportRequested extends PaymentsEvent {}

// ── States ─────────────────────────────────────────────────────────────
