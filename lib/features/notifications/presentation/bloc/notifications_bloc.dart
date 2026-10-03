import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notifications_usecases.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationHistory _getHistory;
  final SendNotification _send;
  final SendExpiryReminders _sendExpiry;
  final DeleteNotification _delete;
  final ClearAllNotifications _clearAll;

  List<NotificationEntity> _history = [];

  NotificationsBloc({
    required GetNotificationHistory getHistory,
    required SendNotification send,
    required SendExpiryReminders sendExpiry,
    required DeleteNotification delete,
    required ClearAllNotifications clearAll,
  }) : _getHistory = getHistory,
       _send = send,
       _sendExpiry = sendExpiry,
       _delete = delete,
       _clearAll = clearAll,
       super(NotificationsInitial()) {
    on<NotificationsEvent>((event, emit) async {
      if (event is NotificationsHistoryRequested) {
        await _onHistory(event, emit);
        return;
      }
      if (event is NotificationSendRequested) {
        await _onSend(event, emit);
        return;
      }
      if (event is NotificationExpiryRemindersRequested) {
        await _onExpiry(event, emit);
        return;
      }
      if (event is NotificationDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
      if (event is NotificationsClearAllRequested) {
        await _onClearAll(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  // ── Load History ✅ Fixed ─────────────────────────────────────────────
  Future<void> _onHistory(
    NotificationsHistoryRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());

    try {
      final result = await _getHistory();

      if (result.isLeft()) {
        // ✅ Keep existing history on error, show error message
        final errMsg = result.fold((f) => f, (_) => 'Failed to load');
        emit(NotificationsError(message: errMsg, history: _history));
        return;
      }

      final loaded = result.getOrElse(() => <NotificationEntity>[]);
      _history = loaded;
      emit(NotificationsLoaded(_history));
    } catch (e) {
      emit(
        NotificationsError(
          message: 'Failed to load notifications: $e',
          history: _history,
        ),
      );
    }
  }

  // ── Send ✅ Fixed ─────────────────────────────────────────────────────
  Future<void> _onSend(
    NotificationSendRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsSending());

    try {
      final result = await _send(
        title: e.title,
        body: e.body,
        targetGroup: e.targetGroup,
        targetUserIds: e.targetUserIds,
        type: e.type,
      );

      if (emit.isDone) return;

      if (result.isLeft()) {
        final latest = await _getHistory();
        if (emit.isDone) return;
        _history = latest.getOrElse(() => _history);
        final errMsg = result.fold((f) => f, (_) => 'Failed to send');
        emit(NotificationsError(message: errMsg, history: _history));
        return;
      }

      // ✅ Reload history after successful send
      final histResult = await _getHistory();
      if (!emit.isDone) {
        _history = histResult.getOrElse(() => _history);
        emit(
          NotificationsSentSuccess(
            message: 'Push request accepted. Device delivery is not confirmed.',
            history: _history,
          ),
        );
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(
          NotificationsError(message: 'Failed to send: $e', history: _history),
        );
      }
    }
  }

  // ── Expiry Reminders ✅ Fixed ─────────────────────────────────────────
  Future<void> _onExpiry(
    NotificationExpiryRemindersRequested e,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsSending());

    try {
      final result = await _sendExpiry();

      if (emit.isDone) return;

      result.fold(
        (err) => emit(NotificationsError(message: err, history: _history)),
        (_) {
          emit(
            NotificationsSentSuccess(
              message: 'Expiry reminders triggered successfully! ✅',
              history: _history,
            ),
          );
          // ✅ Reload history after sending
          add(NotificationsHistoryRequested());
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(
          NotificationsError(
            message: 'Failed to trigger reminders: $e',
            history: _history,
          ),
        );
      }
    }
  }

  // ── Delete Notification ──────────────────────────────────────────────
  Future<void> _onDelete(
    NotificationDeleteRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    // Get the current list from the state
    final currentState = state;
    List<NotificationEntity> currentHistory = [];
    if (currentState is NotificationsLoaded) {
      currentHistory = currentState.history;
    } else if (currentState is NotificationsSentSuccess) {
      currentHistory = currentState.history;
    } else if (currentState is NotificationActionSuccess) {
      currentHistory = currentState.history;
    } else if (currentState is NotificationsError) {
      currentHistory = currentState.history;
    } else {
      currentHistory = _history;
    }

    final result = await _delete(event.id);

    result.fold(
      (error) {
        emit(NotificationsError(message: error, history: currentHistory));
      },
      (_) {
        final updatedHistory = List<NotificationEntity>.from(currentHistory)
          ..removeWhere((notif) => notif.id == event.id);
        _history = updatedHistory;

        emit(
          NotificationActionSuccess(
            message: 'Notification deleted successfully!',
            history: updatedHistory,
          ),
        );
      },
    );
  }

  // ── Clear All Notifications ────────────────────────────────────────
  Future<void> _onClearAll(
    NotificationsClearAllRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    final result = await _clearAll();

    result.fold(
      (error) {
        emit(
          NotificationsError(
            message: error,
            history: _history, // keep current history on error
          ),
        );
      },
      (_) {
        _history = []; // clear local cache

        emit(
          NotificationActionSuccess(
            message: 'All notifications cleared successfully!',
            history: [], // emit empty list
          ),
        );
      },
    );
  }
}
