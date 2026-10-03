import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/csv_download.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/payment_entity.dart';
import '../bloc/payments_bloc.dart';

part '../widgets/payments_page/summary_cards.dart';
part '../widgets/payments_page/filters_row.dart';
part '../widgets/payments_page/drop_filter.dart';
part '../widgets/payments_page/payments_table.dart';
part '../widgets/payments_page/t_h.dart';
part '../widgets/payments_page/payment_row.dart';
part '../widgets/payments_page/payment_card_list.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});
  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  final _searchCtrl = TextEditingController();
  Map<String, String> _plans = {};
  String _statusFilter = 'all';
  String _planFilter = 'all';
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    context.read<PaymentsBloc>().add(PaymentsLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _exportCsv(String csv) => downloadCsv(csv);

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<PaymentsBloc, PaymentsState>(
      listener: (context, state) {
        if (state is PaymentsExportReady) {
          _exportCsv(state.csvContent);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CSV exported successfully!'),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is PaymentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      buildWhen: (_, state) => state is! PaymentsExportReady,
      builder: (context, state) {
        if (state is PaymentsLoaded) {
          _plans = {for (final p in state.payments) p.planId: p.planLabel};
        }
        final loading = state is PaymentsLoading;
        final payments = state is PaymentsLoaded
            ? state.filtered
            : <PaymentEntity>[];
        final summary = state is PaymentsLoaded ? state.summary : null;

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment receipts', style: DTextStyles.h2),
                        Text(
                          '${payments.length} receipts — all environments',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Export CSV
                  if (!isMobile)
                    OutlinedButton.icon(
                      onPressed: loading
                          ? null
                          : () => context.read<PaymentsBloc>().add(
                              PaymentsExportRequested(),
                            ),
                      icon: const Icon(Icons.download_outlined, size: 16),
                      label: const Text('Export CSV'),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: DColors.primary),
                    onPressed: loading
                        ? null
                        : () => context.read<PaymentsBloc>().add(
                            PaymentsLoadRequested(
                              statusFilter: _statusFilter == 'all'
                                  ? null
                                  : _statusFilter,
                              planFilter: _planFilter == 'all'
                                  ? null
                                  : _planFilter,
                              from: _from,
                              to: _to,
                            ),
                          ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              const Text(
                'Revenue totals include confirmed Live GHS receipts only. Sandbox and unknown-environment receipts remain in the history. Dates use Ghana time (UTC).',
              ),
              const SizedBox(height: 8),
              // ── Summary Cards ────────────────────
              if (summary != null) _SummaryCards(summary: summary),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Filters ──────────────────────────
              _FiltersRow(
                plans: _plans,
                searchCtrl: _searchCtrl,
                statusFilter: _statusFilter,
                planFilter: _planFilter,
                from: _from,
                to: _to,
                isMobile: isMobile,
                onSearch: (q) =>
                    context.read<PaymentsBloc>().add(PaymentsSearchChanged(q)),
                onStatusChanged: (v) {
                  setState(() => _statusFilter = v ?? 'all');
                  context.read<PaymentsBloc>().add(
                    PaymentsFilterApplied(
                      statusFilter: v == 'all' ? null : v,
                      planFilter: _planFilter == 'all' ? null : _planFilter,
                      from: _from,
                      to: _to,
                    ),
                  );
                },
                onPlanChanged: (v) {
                  setState(() => _planFilter = v ?? 'all');
                  context.read<PaymentsBloc>().add(
                    PaymentsFilterApplied(
                      statusFilter: _statusFilter == 'all'
                          ? null
                          : _statusFilter,
                      planFilter: v == 'all' ? null : v,
                      from: _from,
                      to: _to,
                    ),
                  );
                },
                onDateRange: (from, to) {
                  setState(() {
                    _from = from;
                    _to = to;
                  });
                  context.read<PaymentsBloc>().add(
                    PaymentsFilterApplied(
                      statusFilter: _statusFilter == 'all'
                          ? null
                          : _statusFilter,
                      planFilter: _planFilter == 'all' ? null : _planFilter,
                      from: from,
                      to: to,
                    ),
                  );
                },
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Table/Cards ──────────────────────
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (state is PaymentsError)
                EmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load receipts',
                  subtitle: state.message,
                )
              else if (payments.isEmpty)
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No payments found',
                  subtitle: 'Try adjusting filters',
                )
              else if (isMobile || isTablet)
                _PaymentCardList(payments: payments)
              else
                _PaymentsTable(payments: payments),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Summary Cards
// ─────────────────────────────────────────────
