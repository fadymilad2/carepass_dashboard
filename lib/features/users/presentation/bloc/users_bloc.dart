import '../../../../core/utils/sequential_events.dart';
import '../../../../core/utils/reporting.dart';
import 'package:carepass_dashboard/features/users/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/users_usecases.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsers _getUsers;
  final UpdateUserStatus _updateStatus;
  final ExtendSubscription _extendSub;

  List<UserEntity> _allUsers = [];
  String _statusFilter = 'all';
  String _searchQuery = '';

  UsersBloc({
    required GetUsers getUsers,
    required UpdateUserStatus updateStatus,
    required ExtendSubscription extendSub,
  }) : _getUsers = getUsers,
       _updateStatus = updateStatus,
       _extendSub = extendSub,
       super(UsersInitial()) {
    on<UsersEvent>((event, emit) async {
      if (event is UsersLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is UsersSearchChanged) {
        _onSearch(event, emit);
        return;
      }
      if (event is UsersFilterChanged) {
        _onFilter(event, emit);
        return;
      }
      if (event is UserStatusUpdateRequested) {
        await _onStatusUpdate(event, emit);
        return;
      }
      if (event is UserExtendSubscriptionRequested) {
        await _onExtend(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  List<UserEntity> _applyFilters() {
    return _allUsers.where((u) {
      final q = _searchQuery.trim().toLowerCase();
      final matchSearch =
          q.isEmpty ||
          u.username.toLowerCase().contains(q) ||
          (u.email?.toLowerCase().contains(q) ?? false) ||
          u.phoneNumber.toLowerCase().contains(q) ||
          u.memberId.toLowerCase().contains(q);

      final matchStatus =
          _statusFilter == 'all' || u.subscriptionStatus == _statusFilter;

      return matchSearch && matchStatus;
    }).toList();
  }

  UserStats _buildStats() => UserStats(
    total: _allUsers.length,
    active: _allUsers.where((u) => u.isActive).length,
    expired: _allUsers.where((u) => u.isExpired).length,
    suspended: _allUsers.where((u) => u.isSuspended).length,
    noPlan: _allUsers.where((u) => u.hasNoPlan).length,
  );

  Future<void> _onLoad(UsersLoadRequested e, Emitter<UsersState> emit) async {
    emit(UsersLoading());
    final result = await _getUsers();

    if (result.isLeft()) {
      emit(UsersError(result.fold((f) => f, (_) => '')));
      return;
    }

    _allUsers = result.getOrElse(() => []);
    emit(
      UsersLoaded(
        allUsers: _allUsers,
        filtered: _applyFilters(),
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
        stats: _buildStats(),
      ),
    );
  }

  void _onSearch(UsersSearchChanged e, Emitter<UsersState> emit) {
    _searchQuery = e.query;
    if (state is UsersLoaded || state is UsersActionSuccess) {
      emit(
        UsersLoaded(
          allUsers: _allUsers,
          filtered: _applyFilters(),
          statusFilter: _statusFilter,
          searchQuery: _searchQuery,
          stats: _buildStats(),
        ),
      );
    }
  }

  void _onFilter(UsersFilterChanged e, Emitter<UsersState> emit) {
    _statusFilter = e.status;
    if (state is UsersLoaded || state is UsersActionSuccess) {
      emit(
        UsersLoaded(
          allUsers: _allUsers,
          filtered: _applyFilters(),
          statusFilter: _statusFilter,
          searchQuery: _searchQuery,
          stats: _buildStats(),
        ),
      );
    }
  }

  Future<void> _onStatusUpdate(
    UserStatusUpdateRequested e,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoaded && state is! UsersActionSuccess) return;

    emit(
      UsersUpdating(
        users: _allUsers,
        filter: _statusFilter,
        query: _searchQuery,
      ),
    );

    final result = await _updateStatus(userId: e.userId, status: e.status);

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(UsersError(result.fold((f) => f, (_) => '')));
      return;
    }

    // Update locally
    _allUsers = _allUsers.map((u) {
      if (u.id == e.userId) {
        return UserModel(
          id: u.id,
          username: u.username,
          phoneNumber: u.phoneNumber,
          email: u.email,
          city: u.city,
          emergencyContact: u.emergencyContact,
          subscriptionStatus: effectiveStatus({
            'subscriptionStatus': e.status,
            'cardExpiryDate': u.cardExpiryDate,
          }, DateTime.now().toUtc()),
          bloodType: u.bloodType,
          planName: u.planName,
          memberId: u.memberId,
          cardExpiryDate: u.cardExpiryDate,
          createdAt: u.createdAt,
          selectedArea: u.selectedArea,
          fcmToken: u.fcmToken,
        );
      }
      return u;
    }).toList();

    emit(
      UsersActionSuccess(
        message: 'Status updated to ${e.status}',
        allUsers: _allUsers,
        filtered: _applyFilters(),
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
        stats: _buildStats(),
      ),
    );
  }

  Future<void> _onExtend(
    UserExtendSubscriptionRequested e,
    Emitter<UsersState> emit,
  ) async {
    if (state is! UsersLoaded && state is! UsersActionSuccess) return;

    emit(
      UsersUpdating(
        users: _allUsers,
        filter: _statusFilter,
        query: _searchQuery,
      ),
    );

    final result = await _extendSub(userId: e.userId, days: e.days);

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(UsersError(result.fold((f) => f, (_) => '')));
      return;
    }

    // Reload fresh data
    final fresh = await _getUsers();
    if (emit.isDone) return;
    if (fresh.isLeft()) {
      emit(
        const UsersError(
          'Subscription updated, but refresh failed. Please reload.',
        ),
      );
      return;
    }
    _allUsers = fresh.getOrElse(() => _allUsers);

    emit(
      UsersActionSuccess(
        message: 'Subscription extended by ${e.days} days',
        allUsers: _allUsers,
        filtered: _applyFilters(),
        statusFilter: _statusFilter,
        searchQuery: _searchQuery,
        stats: _buildStats(),
      ),
    );
  }
}
