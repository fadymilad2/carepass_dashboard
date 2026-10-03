import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../data/models/provider_model.dart';
import '../../domain/entities/provider_entity.dart';
import '../bloc/providers_bloc.dart';
import '../widgets/provider_form.dart';
import '../widgets/providers_grid.dart';
import '../widgets/providers_table.dart';

part '../widgets/providers_page/manage_types_dialog.dart';
part '../widgets/providers_page/search_field.dart';
part '../widgets/providers_page/type_filter.dart';
part '../widgets/providers_page/status_filter.dart';

class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});
  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProvidersBloc>().add(ProvidersLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<ProvidersBloc, ProvidersState>(
      listener: (context, state) {
        if (state is ProvidersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is ProvidersError) {
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
        final loading = state is ProvidersLoading;

        List<ProviderEntity> filtered = [];
        List<ProviderEntity> all = [];
        String typeFilter = 'all';
        String statusFilter = 'all';

        if (state is ProvidersLoaded) {
          filtered = state.filtered;
          all = state.all;
          typeFilter = state.typeFilter;
          statusFilter = state.statusFilter;
        } else if (state is ProvidersActionSuccess) {
          filtered = state.filtered;
          all = state.all;
          typeFilter = state.typeFilter;
          statusFilter = state.statusFilter;
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
                        Text('Providers', style: DTextStyles.h2),
                        Text(
                          '${all.length} total · '
                          '${all.where((p) => p.isActive).length} active',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Refresh
                  IconButton(
                    icon: const Icon(Icons.refresh, color: DColors.primary),
                    onPressed: loading
                        ? null
                        : () => context.read<ProvidersBloc>().add(
                            ProvidersLoadRequested(),
                          ),
                  ),

                  const SizedBox(width: 8),

                  // ✅ Manage Types button
                  OutlinedButton.icon(
                    onPressed: () => _showManageTypes(context),
                    icon: const Icon(Icons.settings_outlined, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Types'),
                  ),

                  const SizedBox(width: 8),

                  // Add Provider
                  ElevatedButton.icon(
                    onPressed: () => _showProviderForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Add Provider'),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Search + Filters ─────────────────
              if (isMobile)
                Column(
                  children: [
                    _SearchField(
                      ctrl: _searchCtrl,
                      onChanged: (q) => context.read<ProvidersBloc>().add(
                        ProvidersSearchChanged(q),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeFilter(
                            value: typeFilter,
                            onChanged: (v) => context.read<ProvidersBloc>().add(
                              ProvidersTypeFilterChanged(v ?? 'all'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StatusFilter(
                            value: statusFilter,
                            onChanged: (v) => context.read<ProvidersBloc>().add(
                              ProvidersStatusFilterChanged(v ?? 'all'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _SearchField(
                        ctrl: _searchCtrl,
                        onChanged: (q) => context.read<ProvidersBloc>().add(
                          ProvidersSearchChanged(q),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _TypeFilter(
                      value: typeFilter,
                      onChanged: (v) => context.read<ProvidersBloc>().add(
                        ProvidersTypeFilterChanged(v ?? 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusFilter(
                      value: statusFilter,
                      onChanged: (v) => context.read<ProvidersBloc>().add(
                        ProvidersStatusFilterChanged(v ?? 'all'),
                      ),
                    ),
                  ],
                ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Content ─────────────────────────
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (filtered.isEmpty)
                EmptyState(
                  icon: Icons.local_hospital_outlined,
                  title: 'No providers found',
                  subtitle: 'Add your first provider to get started',
                  action: ElevatedButton.icon(
                    onPressed: () => _showProviderForm(context, null),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Provider'),
                  ),
                )
              else if (isMobile || isTablet)
                ProvidersGrid(
                  providers: filtered,
                  onEdit: (p) => _showProviderForm(context, p),
                  onToggle: (p) => context.read<ProvidersBloc>().add(
                    ProviderToggleStatusRequested(
                      providerId: p.id,
                      isActive: !p.isActive,
                    ),
                  ),
                  onDelete: (p) => _confirmDelete(context, p),
                )
              else
                ProvidersTable(
                  providers: filtered,
                  onEdit: (p) => _showProviderForm(context, p),
                  onToggle: (p) => context.read<ProvidersBloc>().add(
                    ProviderToggleStatusRequested(
                      providerId: p.id,
                      isActive: !p.isActive,
                    ),
                  ),
                  onDelete: (p) => _confirmDelete(context, p),
                ),
            ],
          ),
        );
      },
    );
  }

  // ── Show Provider Form ─────────────────────────────────────────────
  void _showProviderForm(BuildContext context, ProviderEntity? provider) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProvidersBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ProviderFormSheet(
            provider: provider != null ? provider as ProviderModel : null,
          ),
        ),
      ),
    );
  }

  // ✅ Manage Types ───────────────────────────────────────────────────
  void _showManageTypes(BuildContext context) {
    showDialog(context: context, builder: (_) => const _ManageTypesDialog());
  }

  // ── Confirm Delete ─────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, ProviderEntity provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: DColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DDimens.radiusLG),
        ),
        title: Text('Delete Provider', style: DTextStyles.h3),
        content: Text(
          'Are you sure you want to delete "${provider.name}"? '
          'This action cannot be undone.',
          style: DTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: DTextStyles.label),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ProvidersBloc>().add(
                ProviderDeleteRequested(provider.id),
              );
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Manage Types Dialog
// ─────────────────────────────────────────────
