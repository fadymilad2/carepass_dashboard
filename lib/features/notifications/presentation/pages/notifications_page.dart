import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/dashboard_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notifications_bloc.dart';

part '../widgets/notifications_page/desktop_layout.dart';
part '../widgets/notifications_page/mobile_layout.dart';
part '../widgets/notifications_page/tab_button.dart';
part '../widgets/notifications_page/compose_panel.dart';
part '../widgets/notifications_page/history_panel.dart';
part '../widgets/notifications_page/history_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(NotificationsHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final padding = Responsive.padding(context);

    return BlocConsumer<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsSentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is NotificationActionSuccess) {
          // ✅ Handle general success actions (like delete)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        if (state is NotificationsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final loading = state is NotificationsLoading;
        final sending = state is NotificationsSending;
        final history = _extractHistory(state);

        return Padding(
          padding: EdgeInsets.all(padding),
          child: isMobile || isTablet
              ? _MobileLayout(
                  history: history,
                  loading: loading,
                  sending: sending,
                )
              : _DesktopLayout(
                  history: history,
                  loading: loading,
                  sending: sending,
                ),
        );
      },
    );
  }

  List<NotificationEntity> _extractHistory(NotificationsState state) {
    if (state is NotificationsLoaded) return state.history;
    if (state is NotificationsSentSuccess) return state.history;
    if (state is NotificationActionSuccess) return state.history;
    if (state is NotificationsError) return state.history;
    return [];
  }
}

// ─────────────────────────────────────────────
//  Desktop: Side by side (unchanged)
// ─────────────────────────────────────────────
