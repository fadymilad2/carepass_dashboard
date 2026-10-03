part of '../../pages/notifications_page.dart';

class _HistoryTile extends StatelessWidget {
  final NotificationEntity notif;
  const _HistoryTile({super.key, required this.notif});

  Color get _typeColor {
    switch (notif.type) {
      case 'promo':
        return DColors.success;
      case 'subscription_expiry':
        return DColors.warning;
      case 'system':
        return DColors.error;
      default:
        return DColors.info;
    }
  }

  IconData get _typeIcon {
    switch (notif.type) {
      case 'promo':
        return Icons.local_offer_outlined;
      case 'subscription_expiry':
        return Icons.schedule_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateStr = '';
    try {
      dateStr = DateFormat(
        'MMM d, y · h:mm a',
      ).format(DateTime.parse(notif.createdAt));
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: DTextStyles.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        notif.typeLabel,
                        style: DTextStyles.labelSmall.copyWith(
                          color: _typeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  notif.body,
                  style: DTextStyles.body.copyWith(
                    color: DColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 12,
                      color: DColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(notif.targetLabel, style: DTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.send_outlined,
                      size: 12,
                      color: DColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(notif.deliveryLabel, style: DTextStyles.bodySmall),
                    const Spacer(),
                    Text(dateStr, style: DTextStyles.labelSmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SmallIconBtn(
            icon: Icons.delete_outline,
            color: DColors.error,
            tooltip: 'Delete from history',
            onTap: () async {
              final confirm = await showConfirmDialog(
                context,
                title: 'Delete Notification',
                message: 'Delete "${notif.title}"? This cannot be undone.',
              );
              if (confirm == true && context.mounted) {
                // تأخير إرسال الحدث لضمان اكتمال عملية إغلاق مربع الحوار
                Future.microtask(() {
                  if (context.mounted) {
                    // إعادة التحقق من mounted بعد التأخير
                    context.read<NotificationsBloc>().add(
                      NotificationDeleteRequested(notif.id),
                    );
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
