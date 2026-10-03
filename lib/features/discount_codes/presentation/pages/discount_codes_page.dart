import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../data/models/discount_model.dart';
import '../../domain/entities/discount_entity.dart';
import '../bloc/discount_bloc.dart';

part '../widgets/discount_codes_page/code_table.dart';
part '../widgets/discount_codes_page/t_h.dart';
part '../widgets/discount_codes_page/code_row.dart';
part '../widgets/discount_codes_page/code_card_list.dart';
part '../widgets/discount_codes_page/info_pill.dart';
part '../widgets/discount_codes_page/usage_dialog.dart';
part '../widgets/discount_codes_page/create_code_sheet.dart';

class DiscountCodesPage extends StatefulWidget {
  const DiscountCodesPage({super.key});
  @override
  State<DiscountCodesPage> createState() => _DiscountCodesPageState();
}

class _DiscountCodesPageState extends State<DiscountCodesPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<DiscountBloc>().add(DiscountLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<DiscountBloc, DiscountState>(
      listener: (context, state) {
        if (state is DiscountActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is DiscountError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is DiscountLoading;

        List<DiscountCodeEntity> codes = [];
        List<DiscountCodeEntity> filtered = [];
        int activeCount = 0;
        int totalUses = 0;
        int bulkCount = 0;

        if (state is DiscountLoaded) {
          codes = state.all;
          filtered = state.filtered;
          activeCount = state.activeCount;
          totalUses = state.totalUses;
          bulkCount = state.bulkCount;
        } else if (state is DiscountActionSuccess) {
          codes = state.all;
          filtered = state.filtered;
          activeCount = state.all
              .where((c) => c.isActive && !c.isExpired)
              .length;
          totalUses = state.all.fold(0, (s, c) => s + c.usedCount);
          bulkCount = state.all.where((c) => c.isBulk).length;
        }

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
                        Text('Discount Codes', style: DTextStyles.h2),
                        Text(
                          '${codes.length} codes total',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: DColors.primary),
                    onPressed: loading
                        ? null
                        : () => context.read<DiscountBloc>().add(
                            DiscountLoadRequested(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Create Code'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Stats ────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    MiniStatChip(
                      label: 'Total',
                      value: '${codes.length}',
                      color: DColors.primary,
                    ),
                    const SizedBox(width: 8),
                    MiniStatChip(
                      label: 'Active',
                      value: '$activeCount',
                      color: DColors.success,
                    ),
                    const SizedBox(width: 8),
                    MiniStatChip(
                      label: 'Total Uses',
                      value: '$totalUses',
                      color: DColors.info,
                    ),
                    const SizedBox(width: 8),
                    MiniStatChip(
                      label: 'Bulk/Org',
                      value: '$bulkCount',
                      color: DColors.warning,
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Search ───────────────────────────
              TextField(
                controller: _searchCtrl,
                onChanged: (q) =>
                    context.read<DiscountBloc>().add(DiscountSearchChanged(q)),
                decoration: InputDecoration(
                  hintText: 'Search codes, organization...',
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 18,
                    color: DColors.textSecondary,
                  ),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            context.read<DiscountBloc>().add(
                              DiscountSearchChanged(''),
                            );
                          },
                        )
                      : null,
                ),
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Content ──────────────────────────
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (filtered.isEmpty)
                EmptyState(
                  icon: Icons.discount_outlined,
                  title: 'No discount codes',
                  subtitle: 'Create your first promo code',
                  action: ElevatedButton.icon(
                    onPressed: () => _showCreateSheet(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Code'),
                  ),
                )
              else if (isMobile)
                _CodeCardList(
                  codes: filtered,
                  onToggle: (c) => context.read<DiscountBloc>().add(
                    DiscountCodeToggleRequested(
                      id: c.id,
                      isActive: !c.isActive,
                    ),
                  ),
                  onDelete: (c) => _confirmDelete(context, c),
                  onViewUsage: (c) => _showUsageDialog(context, c),
                )
              else
                _CodeTable(
                  codes: filtered,
                  onToggle: (c) => context.read<DiscountBloc>().add(
                    DiscountCodeToggleRequested(
                      id: c.id,
                      isActive: !c.isActive,
                    ),
                  ),
                  onDelete: (c) => _confirmDelete(context, c),
                  onViewUsage: (c) => _showUsageDialog(context, c),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<DiscountBloc>(),
        child: const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(24),
          child: _CreateCodeSheet(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DiscountCodeEntity code,
  ) async {
    final confirm = await showConfirmDialog(
      context,
      title: 'Delete Code',
      message: 'Delete "${code.code}"? This cannot be undone.',
      confirmLabel: 'Delete',
    );

    if (confirm == true && context.mounted) {
      // ⏳ هندي فرصة للأنيميشن بتاع الدايالوج يخلص والـ Navigator يفك
      await Future.delayed(const Duration(milliseconds: 250));

      if (!context.mounted) return;
      context.read<DiscountBloc>().add(DiscountCodeDeleteRequested(code.id));
      // Use addPostFrameCallback to ensure the dialog is fully dismissed
      // and the Navigator is stable before updating the UI. This is more robust
      // than a fixed delay.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<DiscountBloc>().add(
            DiscountCodeDeleteRequested(code.id),
          );
        }
      });
    }
  }

  void _showUsageDialog(BuildContext context, DiscountCodeEntity code) {
    showDialog(
      context: context,
      builder: (_) => _UsageDialog(code: code),
    );
  }
}

// ─────────────────────────────────────────────
//  Desktop Table
// ─────────────────────────────────────────────
