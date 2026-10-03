import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/users_bloc.dart';
import '../widgets/user_detail_sheet.dart';
import '../widgets/users_table.dart';
import '../widgets/users_card_list.dart';

part '../widgets/users_page/user_detail_with_edit.dart';
part '../widgets/users_page/edit_user_sheet.dart';
part '../widgets/users_page/f.dart';
part '../widgets/users_page/search_field.dart';
part '../widgets/users_page/status_filter.dart';
part '../widgets/users_page/plan_filter.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchCtrl = TextEditingController();
  String _planFilter = 'all'; // ✅ Local plan filter

  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(UsersLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ Filter users by plan locally
  List<UserEntity> _filterByPlan(List<UserEntity> users) {
    if (_planFilter == 'all') return users;
    return users.where((u) {
      final plan = (u.planName).toLowerCase().trim();
      return plan == _planFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<UsersBloc, UsersState>(
      listener: (context, state) {
        if (state is UsersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is UsersError) {
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
        final loading = state is UsersLoading;
        final updating = state is UsersUpdating;

        List<UserEntity> filtered = [];
        List<UserEntity> allUsers = [];
        String statusFilter = 'all';
        UserStats? stats;

        if (state is UsersLoaded) {
          filtered = state.filtered;
          allUsers = state.allUsers;
          statusFilter = state.statusFilter;
          stats = state.stats;
        } else if (state is UsersActionSuccess) {
          filtered = state.filtered;
          allUsers = state.allUsers;
          statusFilter = state.statusFilter;
          stats = state.stats;
        } else if (state is UsersUpdating) {
          filtered = state.users;
          allUsers = state.users;
        }

        // ✅ Apply plan filter on top of status filter
        final displayedUsers = _filterByPlan(filtered);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Users', style: DTextStyles.h2),
                        Text(
                          '${displayedUsers.length} of ${allUsers.length} users',
                          style: DTextStyles.body.copyWith(
                            color: DColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: loading
                        ? null
                        : () => context.read<UsersBloc>().add(
                            UsersLoadRequested(),
                          ),
                    icon: loading || updating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: DColors.primary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh, color: DColors.primary),
                    tooltip: 'Refresh',
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Stats chips ─────────────────────────
              if (stats != null)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      MiniStatChip(
                        label: 'Total',
                        value: '${stats.total}',
                        color: DColors.primary,
                      ),
                      const SizedBox(width: 8),
                      MiniStatChip(
                        label: 'Active',
                        value: '${stats.active}',
                        color: DColors.success,
                      ),
                      const SizedBox(width: 8),
                      MiniStatChip(
                        label: 'Expired',
                        value: '${stats.expired}',
                        color: DColors.warning,
                      ),
                      const SizedBox(width: 8),
                      MiniStatChip(
                        label: 'Suspended',
                        value: '${stats.suspended}',
                        color: DColors.error,
                      ),
                      const SizedBox(width: 8),
                      MiniStatChip(
                        label: 'No Plan',
                        value: '${stats.noPlan}',
                        color: DColors.textSecondary,
                      ),
                    ],
                  ),
                ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Search + Filters ────────────────────
              if (isMobile)
                Column(
                  children: [
                    _SearchField(
                      ctrl: _searchCtrl,
                      onChanged: (q) =>
                          context.read<UsersBloc>().add(UsersSearchChanged(q)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _StatusFilter(
                            value: statusFilter,
                            onChanged: (v) => context.read<UsersBloc>().add(
                              UsersFilterChanged(v ?? 'all'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // ✅ Plan Filter
                        Expanded(
                          child: _PlanFilter(
                            value: _planFilter,
                            onChanged: (v) =>
                                setState(() => _planFilter = v ?? 'all'),
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
                        onChanged: (q) => context.read<UsersBloc>().add(
                          UsersSearchChanged(q),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusFilter(
                      value: statusFilter,
                      onChanged: (v) => context.read<UsersBloc>().add(
                        UsersFilterChanged(v ?? 'all'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ✅ Plan Filter
                    _PlanFilter(
                      value: _planFilter,
                      onChanged: (v) =>
                          setState(() => _planFilter = v ?? 'all'),
                    ),
                  ],
                ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Content ─────────────────────────────
              if (loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (displayedUsers.isEmpty)
                EmptyState(
                  icon: Icons.people_outline,
                  title: 'No users found',
                  subtitle: 'Try adjusting search or filter',
                )
              else
                isMobile
                    ? UsersCardList(
                        users: displayedUsers,
                        onView: (u) => _showDetail(context, u),
                        onStatusChange: (id, s) =>
                            context.read<UsersBloc>().add(
                              UserStatusUpdateRequested(userId: id, status: s),
                            ),
                      )
                    : UsersTable(
                        users: displayedUsers,
                        onView: (u) => _showDetail(context, u),
                        onStatusChange: (id, s) =>
                            context.read<UsersBloc>().add(
                              UserStatusUpdateRequested(userId: id, status: s),
                            ),
                      ),
            ],
          ),
        );
      },
    );
  }

  void _showDetail(BuildContext context, UserEntity user) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<UsersBloc>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: _UserDetailWithEdit(user: user),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ User Detail + Edit Wrapper
// ─────────────────────────────────────────────
