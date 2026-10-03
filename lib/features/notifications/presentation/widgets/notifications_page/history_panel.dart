part of '../../pages/notifications_page.dart';

class _HistoryPanel extends StatelessWidget {
  final List<NotificationEntity> history;
  final bool loading;

  const _HistoryPanel({required this.history, required this.loading});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Notification History',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (history.isNotEmpty)
            TextButton.icon(
              onPressed: () async {
                final confirm = await showConfirmDialog(
                  context,
                  title: 'Clear All History',
                  message:
                      'Are you sure you want to delete all notification history? This cannot be undone.',
                );
                if (confirm == true && context.mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.read<NotificationsBloc>().add(
                        NotificationsClearAllRequested(),
                      );
                    }
                  });
                }
              },
              icon: const Icon(
                Icons.delete_sweep_outlined,
                size: 16,
                color: DColors.error,
              ),
              label: const Text(
                'Clear All',
                style: TextStyle(color: DColors.error),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: DColors.primary, size: 20),
            onPressed: () => context.read<NotificationsBloc>().add(
              NotificationsHistoryRequested(),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.zero,
      child: loading
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: CircularProgressIndicator(color: DColors.primary),
              ),
            )
          : history.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 40,
                      color: DColors.textSecondary,
                    ),
                    SizedBox(height: 8),
                    Text('No notifications sent yet'),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) =>
                  _HistoryTile(key: ValueKey(history[i].id), notif: history[i]),
            ),
    );
  }
}
