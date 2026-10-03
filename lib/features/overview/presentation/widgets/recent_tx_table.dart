import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/overview_entities.dart';

class RecentTxWidget extends StatelessWidget {
  final List<RecentTransaction> transactions;
  const RecentTxWidget({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'No transactions yet',
            style: TextStyle(color: DColors.textSecondary),
          ),
        ),
      );
    }

    return Responsive.isMobile(context)
        ? _CardList(transactions: transactions)
        : _Table(transactions: transactions);
  }
}

// ── Desktop Table ─────────────────────────────────────────────────────
class _Table extends StatelessWidget {
  final List<RecentTransaction> transactions;
  const _Table({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: DColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            children: const [
              Expanded(flex: 2, child: _TH('Reference')),
              Expanded(flex: 1, child: _TH('Plan')),
              Expanded(flex: 1, child: _TH('Amount')),
              Expanded(flex: 1, child: _TH('Date')),
              Expanded(flex: 1, child: _TH('Status')),
            ],
          ),
        ),
        const Divider(height: 1),

        ...transactions.map((tx) {
          String dateStr = '';
          try {
            dateStr = DateFormat('MMM d, y').format(DateTime.parse(tx.date));
          } catch (_) {}

          return Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: DColors.border)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      tx.reference,
                      style: DTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: DColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      tx.planId.isNotEmpty
                          ? tx.planId[0].toUpperCase() + tx.planId.substring(1)
                          : '—',
                      style: DTextStyles.body,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '${tx.currency} ${tx.amount.toStringAsFixed(2)}',
                      style: DTextStyles.label.copyWith(color: DColors.success),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(dateStr, style: DTextStyles.bodySmall),
                  ),
                  Expanded(flex: 1, child: StatusBadge(status: tx.status)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: DTextStyles.label);
  }
}

// ── Mobile Cards ──────────────────────────────────────────────────────
class _CardList extends StatelessWidget {
  final List<RecentTransaction> transactions;
  const _CardList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: transactions.map((tx) {
        String dateStr = '';
        try {
          dateStr = DateFormat('MMM d, y').format(DateTime.parse(tx.date));
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DColors.successLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: DColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tx.planId.isEmpty ? 'Standard' : tx.planId[0].toUpperCase() + tx.planId.substring(1)} Plan',
                      style: DTextStyles.label,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tx.reference,
                      style: DTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: DColors.primary,
                        fontSize: 11,
                      ),
                    ),
                    Text(dateStr, style: DTextStyles.bodySmall),
                  ],
                ),
              ),
              Text(
                '${tx.currency}\n${tx.amount.toStringAsFixed(2)}',
                style: DTextStyles.label.copyWith(color: DColors.success),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
