import '../../../../core/utils/reporting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/usecases/payments_usecases.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'payments_event.dart';
part 'payments_state.dart';

class PaymentsBloc extends Bloc<PaymentsEvent, PaymentsState> {
  final GetPayments _get;
  final GetPaymentSummary _getSummary;
  final ExportPaymentsCsv _export;
  List<PaymentEntity> _all = [];
  PaymentSummary? _summary;
  String _query = '';
  String? _status, _plan;
  DateTime? _from, _to;
  int _loadVersion = 0;
  PaymentsBloc({
    required GetPayments get,
    required GetPaymentSummary getSummary,
    required SearchPayments search,
    required ExportPaymentsCsv export,
  }) : _get = get,
       _getSummary = getSummary,
       _export = export,
       super(PaymentsInitial()) {
    on<PaymentsLoadRequested>((e, emit) async {
      final version = ++_loadVersion;
      _status = e.statusFilter;
      _plan = e.planFilter;
      _from = e.from;
      _to = e.to;
      emit(PaymentsLoading());
      final payments = await _get();
      final summary = await _getSummary();
      if (emit.isDone || version != _loadVersion) return;
      if (payments.isLeft() || summary.isLeft()) {
        emit(
          PaymentsError(
            payments.fold(
              (e) => e,
              (_) => summary.fold((e) => e, (_) => 'Unable to load receipts'),
            ),
          ),
        );
        return;
      }
      _all = payments.getOrElse(() => []);
      _summary = summary.getOrElse(() => throw StateError('Missing summary'));
      emit(_loaded());
    });
    on<PaymentsSearchChanged>((e, emit) {
      _query = e.query;
      if (state is PaymentsLoaded) emit(_loaded());
    });
    on<PaymentsFilterApplied>((e, emit) {
      _status = e.statusFilter;
      _plan = e.planFilter;
      _from = e.from;
      _to = e.to;
      if (state is PaymentsLoaded) emit(_loaded());
    });
    on<PaymentsExportRequested>((e, emit) async {
      if (state is! PaymentsLoaded) return;
      final version = _loadVersion;
      final result = await _export((state as PaymentsLoaded).filtered);
      if (emit.isDone || version != _loadVersion || state is! PaymentsLoaded) {
        return;
      }
      result.fold((e) => emit(PaymentsError(e)), (csv) {
        emit(PaymentsExportReady(csv));
        emit(_loaded());
      });
    });
  }
  PaymentsLoaded _loaded() {
    final q = _query.trim().toLowerCase();
    final rows = _all.where((p) {
      if (_status != null && _status != 'all' && p.status != _status) {
        return false;
      }
      if (_plan != null && _plan != 'all' && p.planId != _plan) return false;
      final date = reportDate(p.createdAt);
      if (_from != null && (date == null || date.isBefore(reportDay(_from!)))) {
        return false;
      }
      if (_to != null &&
          (date == null ||
              !date.isBefore(reportDay(_to!).add(const Duration(days: 1))))) {
        return false;
      }
      return [
        p.reference,
        p.username,
        p.email,
        p.phoneNumber,
        p.planId,
        p.planLabel,
        p.environmentLabel,
      ].any((value) => value.toLowerCase().contains(q));
    }).toList();
    return PaymentsLoaded(
      payments: _all,
      filtered: rows,
      summary: _summary,
      searchQuery: _query,
      statusFilter: _status,
      planFilter: _plan,
      from: _from,
      to: _to,
    );
  }
}
