import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/user_entity.dart';

class UsersCardList extends StatelessWidget {
  final List<UserEntity> users;
  final Function(UserEntity) onView;
  final Function(String, String) onStatusChange;

  const UsersCardList({
    super.key,
    required this.users,
    required this.onView,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: users.map((user) {
        String joinedStr = '';
        try {
          joinedStr = DateFormat(
            'MMM d, y',
          ).format(DateTime.parse(user.createdAt));
        } catch (_) {}

        return GestureDetector(
          onTap: () => onView(user),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: DColors.surface,
              borderRadius: BorderRadius.circular(DDimens.radiusLG),
              border: Border.all(color: DColors.border),
            ),
            child: Column(
              children: [
                // Top: avatar + name + status
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: DColors.primaryLight,
                      child: Text(
                        user.avatarLetter,
                        style: DTextStyles.label.copyWith(
                          color: DColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: DTextStyles.label),
                          Text(
                            user.phoneNumber,
                            style: DTextStyles.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: user.subscriptionStatus),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Bottom: info + actions
                Row(
                  children: [
                    Expanded(
                      child: _InfoCell(label: 'Plan', value: user.planLabel),
                    ),
                    Expanded(
                      child: _InfoCell(label: 'Joined', value: joinedStr),
                    ),
                    // Actions
                    Row(
                      children: [
                        if (!user.isActive)
                          SmallIconBtn(
                            icon: Icons.check_circle_outline,
                            color: DColors.success,
                            tooltip: 'Activate',
                            onTap: () => onStatusChange(user.id, 'active'),
                          )
                        else
                          SmallIconBtn(
                            icon: Icons.block_outlined,
                            color: DColors.error,
                            tooltip: 'Suspend',
                            onTap: () => onStatusChange(user.id, 'suspended'),
                          ),
                        SmallIconBtn(
                          icon: Icons.arrow_forward_ios,
                          color: DColors.textSecondary,
                          tooltip: 'View Details',
                          onTap: () => onView(user),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label, value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DTextStyles.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: DTextStyles.label.copyWith(fontSize: 12)),
      ],
    );
  }
}
