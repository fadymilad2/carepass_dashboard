import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/users_bloc.dart';

class UserDetailSheet extends StatelessWidget {
  final UserEntity user;
  const UserDetailSheet({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String expiryStr = '—';
    try {
      expiryStr = DateFormat(
        'MMMM d, y',
      ).format(DateTime.parse(user.cardExpiryDate));
    } catch (_) {}

    String joinedStr = '—';
    try {
      joinedStr = DateFormat(
        'MMMM d, y',
      ).format(DateTime.parse(user.createdAt));
    } catch (_) {}

    return Container(
      width: 650, // 👈 العرض الثابت اللي ضبط معاك في شاشات الويب
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            0.85, // 👈 أقصى طول لمنع أي Overflow
      ),
      decoration: BoxDecoration(
        color: DColors.surface,
        borderRadius: BorderRadius.circular(20), // 👈 الحواف الدائرية المظبوطة
      ),
      child: Column(
        mainAxisSize: MainAxisSize
            .min, // 👈 بيخلي الـ Container يلم على قد المحتوى بالظبط
        children: [
          // ── Header (Title + Close Icon) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'User Details',
                  style: DTextStyles.h3.copyWith(fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  splashRadius: 20,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Scrollable Body ──
          Flexible(
            child: ListView(
              shrinkWrap:
                  true, // 👈 عشان يلم المقاس أوتوماتيك ويفتح سكرول عند الحاجة بس
              padding: const EdgeInsets.all(24),
              children: [
                // بروفايل اليوزر (Avatar + Name + Phone + Status)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: DColors.primaryLight,
                      child: Text(
                        user.avatarLetter,
                        style: DTextStyles.h2.copyWith(color: DColors.primary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.displayName, style: DTextStyles.h3),
                          const SizedBox(height: 4),
                          Text(
                            user.phoneNumber,
                            style: DTextStyles.body.copyWith(
                              color: DColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (user.isActive ? DColors.success : DColors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              (user.isActive ? DColors.success : DColors.error)
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        user.isActive ? 'Active' : 'Suspended',
                        style: DTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: user.isActive
                              ? DColors.success
                              : DColors.error,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // شبكة البيانات (Grid via Wrap)
                Wrap(
                  spacing: 24,
                  runSpacing: 20,
                  children: [
                    _Cell('Member ID', user.memberId, isCode: true),
                    _Cell(
                      'Plan',
                      '',
                      customChild: Container(
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
                          borderRadius: BorderRadius.circular(20),
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
                    _Cell('Valid Until', expiryStr),
                    _Cell(
                      'Area',
                      user.selectedArea.isEmpty ? '—' : user.selectedArea,
                    ),
                    _Cell('Joined', joinedStr),
                    _Cell('User ID', user.id, isCode: true),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // قسم الـ Actions
                Text('Actions', style: DTextStyles.h3),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!user.isActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<UsersBloc>().add(
                            UserStatusUpdateRequested(
                              userId: user.id,
                              status: 'active',
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Activate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DColors.success,
                        ),
                      ),
                    if (user.isActive)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<UsersBloc>().add(
                            UserStatusUpdateRequested(
                              userId: user.id,
                              status: 'suspended',
                            ),
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.block_outlined, size: 16),
                        label: const Text('Suspend'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DColors.error,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // قسم الـ Extend Subscription
                Text('Extend Subscription', style: DTextStyles.label),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [30, 60, 90, 180, 365]
                      .map(
                        (days) => OutlinedButton(
                          onPressed: () {
                            context.read<UsersBloc>().add(
                              UserExtendSubscriptionRequested(
                                userId: user.id,
                                days: days,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: DColors.primary,
                            side: const BorderSide(color: DColors.primary),
                          ),
                          child: Text(days >= 365 ? '1 Year' : '$days Days'),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String label, value;
  final bool isCode;
  final Widget? customChild;

  const _Cell(this.label, this.value, {this.isCode = false, this.customChild});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          280, // 👈 المقاس ده مضبوط بالمللي عشان يقسم البيانات على عمودين متساويين جوه الـ 650
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DTextStyles.bodySmall),
          const SizedBox(height: 6),
          customChild ??
              Text(
                value,
                style: isCode
                    ? DTextStyles.body.copyWith(
                        fontFamily: 'monospace',
                        color: DColors.primary,
                        fontSize: 12,
                      )
                    : DTextStyles.label,
                overflow: TextOverflow.ellipsis,
              ),
        ],
      ),
    );
  }
}
