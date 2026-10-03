part of '../../pages/notifications_page.dart';

class _MobileLayout extends StatefulWidget {
  final List<NotificationEntity> history;
  final bool loading;
  final bool sending;

  const _MobileLayout({
    required this.history,
    required this.loading,
    required this.sending,
  });

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  // 0 = Send, 1 = History
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          children: [
            Expanded(child: Text('Notifications', style: DTextStyles.h2)),
            IconButton(
              icon: const Icon(Icons.refresh, color: DColors.primary),
              onPressed: () => context.read<NotificationsBloc>().add(
                NotificationsHistoryRequested(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ✅ Manual tab selector — plain Row + GestureDetector,
        // no TabBar/TabController involved
        Container(
          decoration: BoxDecoration(
            color: DColors.surface,
            borderRadius: BorderRadius.circular(DDimens.radiusMD),
            border: Border.all(color: DColors.border),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Expanded(
                child: _TabButton(
                  label: 'Send',
                  selected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
              ),
              Expanded(
                child: _TabButton(
                  label: 'History',
                  selected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ✅ No Expanded — content just sits naturally in the
        // scrollable parent from DashboardShell
        _selectedTab == 0
            ? _ComposePanel(sending: widget.sending)
            : _HistoryPanel(history: widget.history, loading: widget.loading),
      ],
    );
  }
}
