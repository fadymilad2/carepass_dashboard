part of '../../pages/admin_users_page.dart';

class _AdminCardList extends StatelessWidget {
  final List<AdminUserEntity> admins;
  final Function(AdminUserEntity, AdminRole) onRoleChange;
  final Function(AdminUserEntity) onToggle;
  final Function(AdminUserEntity) onDelete;

  const _AdminCardList({
    required this.admins,
    required this.onRoleChange,
    required this.onToggle,
    required this.onDelete,
  });

  static final _presetRoles = AdminRole.values
      .where((r) => r != AdminRole.custom)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: admins.map((admin) {
        String joinedStr = '';
        try {
          joinedStr = DateFormat(
            'MMM d, y',
          ).format(DateTime.parse(admin.createdAt));
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: DColors.surface,
            borderRadius: BorderRadius.circular(DDimens.radiusLG),
            border: Border.all(color: DColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: admin.role.color.withValues(alpha: 0.15),
                    child: Text(
                      admin.avatarLetter,
                      style: DTextStyles.label.copyWith(
                        color: admin.role.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(admin.displayName, style: DTextStyles.label),
                        Text(
                          admin.email,
                          style: DTextStyles.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: admin.isActive,
                    onChanged: (_) => onToggle(admin),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              Row(
                children: [
                  _RoleBadge(role: admin.role),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showManagePermissionsDialog(context, admin),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${admin.permissions.length} permissions',
                          style: DTextStyles.bodySmall.copyWith(
                            color: DColors.primary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: DColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text('Joined $joinedStr', style: DTextStyles.labelSmall),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: admin.role == AdminRole.custom
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: DColors.border),
                              borderRadius: BorderRadius.circular(
                                DDimens.radiusMD,
                              ),
                            ),
                            child: Text(
                              'Custom permission set',
                              style: DTextStyles.bodySmall,
                            ),
                          )
                        : DropdownButtonFormField<AdminRole>(
                            initialValue: admin.role,
                            isDense: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DDimens.radiusMD,
                                ),
                                borderSide: const BorderSide(
                                  color: DColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  DDimens.radiusMD,
                                ),
                                borderSide: const BorderSide(
                                  color: DColors.border,
                                ),
                              ),
                            ),
                            onChanged: (r) {
                              if (r != null) {
                                onRoleChange(admin, r);
                              }
                            },
                            items: _presetRoles
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r.label,
                                      style: DTextStyles.body,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                  const SizedBox(width: 8),
                  SmallIconBtn(
                    icon: Icons.tune,
                    color: DColors.info,
                    tooltip: 'Manage Permissions',
                    onTap: () => _showManagePermissionsDialog(context, admin),
                  ),
                  const SizedBox(width: 8),
                  SmallIconBtn(
                    icon: Icons.delete_outline,
                    color: DColors.error,
                    tooltip: 'Remove',
                    onTap: () => onDelete(admin),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────
//  Role Badge
// ─────────────────────────────────────────────
