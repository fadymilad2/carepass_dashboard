import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../bloc/admin_users_bloc.dart';

part '../widgets/admin_users_page/admin_table.dart';
part '../widgets/admin_users_page/t_h.dart';
part '../widgets/admin_users_page/admin_row.dart';
part '../widgets/admin_users_page/admin_card_list.dart';
part '../widgets/admin_users_page/role_badge.dart';
part '../widgets/admin_users_page/edit_permissions_dialog.dart';
part '../widgets/admin_users_page/add_admin_sheet.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});
  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  List<AdminUserEntity> _admins = [];
  int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminUsersBloc>().add(AdminUsersLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<AdminUsersBloc, AdminUsersState>(
      listener: (context, state) {
        if (state is AdminUsersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // ✅ Fixed — removed the forced AdminUsersLoadRequested()
          // reload that used to run here. It was redundant (the
          // Bloc already patches _admins locally with correct,
          // known-good data for every action — role update,
          // permission update, toggle, delete, and create all
          // already produce a fully up-to-date state on their
          // own) and it introduced a race: firing a brand-new
          // Firestore query immediately after a write sometimes
          // returned data from just before the write had fully
          // settled, which visually looked like the edit had
          // "reverted" even though it had actually saved.
        }
        if (state is AdminUsersError) {
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
        final loading = state is AdminUsersLoading;

        if (state is AdminUsersLoaded) {
          _admins = state.admins;
          _activeCount = state.activeCount;
        } else if (state is AdminUsersActionSuccess) {
          _admins = state.admins;
          _activeCount = _admins.where((a) => a.isActive).length;
        } else if (state is AdminUsersError) {
          _admins = state.admins;
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
                        Text('Admin Users', style: DTextStyles.h2),
                        Text(
                          '${_admins.length} admins · $_activeCount active',
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
                        : () => context.read<AdminUsersBloc>().add(
                            AdminUsersLoadRequested(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAdminSheet(context),
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: isMobile
                        ? const SizedBox.shrink()
                        : const Text('Add Admin'),
                  ),
                ],
              ),

              if (loading && _admins.isNotEmpty) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(color: DColors.primary),
              ],

              SizedBox(height: isMobile ? 12 : 16),

              // ── Role Legend ──────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AdminRole.values.map((role) {
                    final count = _admins.where((a) => a.role == role).length;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: role.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: role.color.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: role.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${role.label} ($count)',
                              style: DTextStyles.bodySmall.copyWith(
                                color: role.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: isMobile ? 12 : 16),

              // ── Content ──────────────────────────
              if (loading && _admins.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(color: DColors.primary),
                  ),
                )
              else if (_admins.isEmpty)
                EmptyState(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'No admin users',
                  subtitle: 'Add your first admin user',
                  action: ElevatedButton.icon(
                    onPressed: () => _showAddAdminSheet(context),
                    icon: const Icon(Icons.person_add_outlined, size: 16),
                    label: const Text('Add Admin'),
                  ),
                )
              else if (isMobile)
                _AdminCardList(
                  admins: _admins,
                  onRoleChange: (a, r) => context.read<AdminUsersBloc>().add(
                    AdminUserRoleUpdateRequested(adminId: a.id, newRole: r),
                  ),
                  onToggle: (a) => context.read<AdminUsersBloc>().add(
                    AdminUserToggleStatusRequested(
                      adminId: a.id,
                      isActive: !a.isActive,
                    ),
                  ),
                  onDelete: (a) => _confirmDelete(context, a),
                )
              else
                _AdminTable(
                  admins: _admins,
                  onRoleChange: (a, r) => context.read<AdminUsersBloc>().add(
                    AdminUserRoleUpdateRequested(adminId: a.id, newRole: r),
                  ),
                  onToggle: (a) => context.read<AdminUsersBloc>().add(
                    AdminUserToggleStatusRequested(
                      adminId: a.id,
                      isActive: !a.isActive,
                    ),
                  ),
                  onDelete: (a) => _confirmDelete(context, a),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddAdminSheet(BuildContext context) {
    final bloc = context.read<AdminUsersBloc>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(24),
          child: _AddAdminSheet(),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminUserEntity admin,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Admin'),
        content: Text(
          'Remove ${admin.displayName} from dashboard access?\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: DColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<AdminUsersBloc>().add(AdminUserDeleteRequested(admin.id));
    }
  }
}

void _showManagePermissionsDialog(BuildContext context, AdminUserEntity admin) {
  final bloc = context.read<AdminUsersBloc>();
  showDialog(
    context: context,
    barrierDismissible: false, // ✅ prevent accidental dismiss mid-save
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _EditPermissionsDialog(admin: admin),
    ),
  );
}

// ─────────────────────────────────────────────
//  Desktop Table
// ─────────────────────────────────────────────
