part of '../../pages/notifications_page.dart';

class _DesktopLayout extends StatelessWidget {
  final List<NotificationEntity> history;
  final bool loading;
  final bool sending;

  const _DesktopLayout({
    required this.history,
    required this.loading,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 400, child: _ComposePanel(sending: sending)),
        const SizedBox(width: 20),
        Expanded(
          child: _HistoryPanel(history: history, loading: loading),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  ✅ Mobile: Manual tabs — NO TabBarView/Expanded
//  (fixes blank-page bug caused by Expanded inside the
//  unbounded SingleChildScrollView in DashboardShell)
// ─────────────────────────────────────────────
