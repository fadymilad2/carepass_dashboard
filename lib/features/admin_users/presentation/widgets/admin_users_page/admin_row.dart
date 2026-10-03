part of '../../pages/admin_users_page.dart';

class _AdminRow extends StatelessWidget {
  final AdminUserEntity admin;
  final Function(AdminRole) onRoleChange;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _AdminRow({
    required this.admin,
    required this.onRoleChange,
    required this.onToggle,
    required this.onDelete,
  });

  static final _presetRoles = AdminRole.values
      .where((r) => r != AdminRole.custom)
      .toList();

  @override
  Widget build(BuildContext context) {
    String joinedStr = '';
    try {
      joinedStr = DateFormat(
        'MMM d, y',
      ).format(DateTime.parse(admin.createdAt));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: admin.role.color.withValues(alpha: 0.15),
                  child: Text(
                    admin.avatarLetter,
                    style: DTextStyles.label.copyWith(
                      color: admin.role.color,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    admin.displayName,
                    style: DTextStyles.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 2,
            child: Text(
              admin.email,
              style: DTextStyles.body,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Expanded(
            flex: 2,
            child: admin.role == AdminRole.custom
                ? Row(
                    children: [
                      _RoleBadge(role: admin.role),
                      const SizedBox(width: 4),
                      Icon(Icons.tune, size: 14, color: DColors.textHint),
                    ],
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<AdminRole>(
                      value: admin.role,
                      isDense: true,
                      onChanged: (r) {
                        if (r != null) onRoleChange(r);
                      },
                      items: _presetRoles
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: _RoleBadge(role: r),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),

          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showManagePermissionsDialog(context, admin),
              child: Row(
                children: [
                  ...admin.permissions
                      .take(2)
                      .map(
                        (p) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: DColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: DColors.border),
                          ),
                          child: Text(
                            p
                                .replaceAll('_', ' ')
                                .replaceAll('manage ', '')
                                .replaceAll('view ', ''),
                            style: DTextStyles.bodySmall.copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                  if (admin.permissions.length > 2)
                    Text(
                      '+${admin.permissions.length - 2}',
                      style: DTextStyles.bodySmall,
                    ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit_outlined, size: 12, color: DColors.textHint),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Switch(value: admin.isActive, onChanged: (_) => onToggle()),
          ),

          Expanded(
            flex: 1,
            child: Text(joinedStr, style: DTextStyles.bodySmall),
          ),

          Expanded(
            flex: 2,
            child: Row(
              children: [
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
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Mobile Card List
// ─────────────────────────────────────────────
