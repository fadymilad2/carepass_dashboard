part of '../../pages/admin_users_page.dart';

class _AdminTable extends StatelessWidget {
  final List<AdminUserEntity> admins;
  final Function(AdminUserEntity, AdminRole) onRoleChange;
  final Function(AdminUserEntity) onToggle;
  final Function(AdminUserEntity) onDelete;

  const _AdminTable({
    required this.admins,
    required this.onRoleChange,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(DDimens.radiusLG),
        border: Border.all(color: DColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: DColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(DDimens.radiusLG),
              ),
            ),
            child: Row(
              children: const [
                Expanded(flex: 2, child: _TH('Admin')),
                Expanded(flex: 2, child: _TH('Email')),
                Expanded(flex: 2, child: _TH('Role')),
                Expanded(flex: 2, child: _TH('Permissions')),
                Expanded(flex: 1, child: _TH('Status')),
                Expanded(flex: 1, child: _TH('Joined')),
                Expanded(flex: 2, child: _TH('Actions')),
              ],
            ),
          ),
          const Divider(height: 1),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: admins.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) => _AdminRow(
              admin: admins[i],
              onRoleChange: (r) => onRoleChange(admins[i], r),
              onToggle: () => onToggle(admins[i]),
              onDelete: () => onDelete(admins[i]),
            ),
          ),
        ],
      ),
    );
  }
}
