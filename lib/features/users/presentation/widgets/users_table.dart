import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/user_entity.dart';

class UsersTable extends StatelessWidget {
  final List<UserEntity> users;
  final Function(UserEntity) onView;
  final Function(String, String) onStatusChange;

  const UsersTable({
    super.key,
    required this.users,
    required this.onView,
    required this.onStatusChange,
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
          // ── Header ─────────────────────────────
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
                Expanded(flex: 2, child: _TH('User')),
                Expanded(flex: 2, child: _TH('Phone Number')),
                Expanded(flex: 1, child: _TH('Member ID')),
                Expanded(flex: 1, child: _TH('Plan')),
                Expanded(flex: 1, child: _TH('Status')),
                Expanded(flex: 1, child: _TH('Joined')),
                Expanded(flex: 2, child: _TH('Actions')),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Rows ───────────────────────────────
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1, color: DColors.border),
            itemBuilder: (_, i) => _UserRow(
              user: users[i],
              onView: () => onView(users[i]),
              onStatusChange: onStatusChange,
            ),
          ),
        ],
      ),
    );
  }
}

class _TH extends StatelessWidget {
  final String text;
  const _TH(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: DTextStyles.label);
}

class _UserRow extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onView;
  final Function(String, String) onStatusChange;

  const _UserRow({
    required this.user,
    required this.onView,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    String joinedStr = '';
    try {
      joinedStr = DateFormat('MMM d, y').format(DateTime.parse(user.createdAt));
    } catch (_) {}

    return InkWell(
      onTap: onView,
      hoverColor: DColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // User + avatar
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: DColors.primaryLight,
                    child: Text(
                      user.avatarLetter,
                      style: DTextStyles.label.copyWith(
                        color: DColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      user.displayName,
                      style: DTextStyles.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Phone Number
            Expanded(
              flex: 2,
              child: Text(
                user.phoneNumber,
                style: DTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Member ID
            Expanded(
              flex: 1,
              child: Text(
                user.memberId,
                style: DTextStyles.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: DColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Plan
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft, // ✅ بيمنع الكونتينر إنه يتمط
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (user.planName == 'Premium' ||
                                    user.planName == 'Annual Premium'
                                ? DColors.primary
                                : DColors.textSecondary)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20), // ✅ شكل بيضاوي شيك
                    border: Border.all(
                      color:
                          (user.planName == 'Premium' ||
                                      user.planName == 'Annual Premium'
                                  ? DColors.primary
                                  : DColors.textSecondary)
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    user.planName.isEmpty ? '—' : user.planName,
                    style: DTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          user.planName == 'Premium' ||
                              user.planName == 'Annual Premium'
                          ? DColors.primary
                          : DColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Status (استغنينا عن StatusBadge هنا عشان نوحد الشكل في الجدول)
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (user.isActive ? DColors.success : DColors.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (user.isActive ? DColors.success : DColors.error)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    user.isActive ? 'Active' : 'Suspended',
                    style: DTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: user.isActive ? DColors.success : DColors.error,
                    ),
                  ),
                ),
              ),
            ),

            // Joined
            Expanded(
              flex: 1,
              child: Text(joinedStr, style: DTextStyles.bodySmall),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  ActionBtn(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    color: DColors.info,
                    onTap: onView,
                  ),
                  const SizedBox(width: 6),
                  if (!user.isActive)
                    ActionBtn(
                      icon: Icons.check_circle_outline,
                      label: 'Activate',
                      color: DColors.success,
                      onTap: () => onStatusChange(user.id, 'active'),
                    )
                  else
                    ActionBtn(
                      icon: Icons.block_outlined,
                      label: 'Suspend',
                      color: DColors.error,
                      onTap: () => onStatusChange(user.id, 'suspended'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
