import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/usecases/admin_users_usecases.dart';
import '../../data/models/admin_user_model.dart';

// ── Events ─────────────────────────────────────────────────────────────
part 'admin_users_event.dart';
part 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAdminUsers _get;
  final CreateAdminUser _create;
  final UpdateAdminRole _updateRole;
  final UpdateAdminPermissions _updatePermissions;
  final ToggleAdminStatus _toggle;
  final DeleteAdminUser _delete;

  List<AdminUserEntity> _admins = [];

  AdminUsersBloc({
    required GetAdminUsers get,
    required CreateAdminUser create,
    required UpdateAdminRole updateRole,
    required UpdateAdminPermissions updatePermissions,
    required ToggleAdminStatus toggle,
    required DeleteAdminUser delete,
  }) : _get = get,
       _create = create,
       _updateRole = updateRole,
       _updatePermissions = updatePermissions,
       _toggle = toggle,
       _delete = delete,
       super(AdminUsersInitial()) {
    on<AdminUsersEvent>((event, emit) async {
      if (event is AdminUsersLoadRequested) {
        await _onLoad(event, emit);
        return;
      }
      if (event is AdminUserCreateRequested) {
        await _onCreate(event, emit);
        return;
      }
      if (event is AdminUserRoleUpdateRequested) {
        await _onUpdateRole(event, emit);
        return;
      }
      if (event is AdminUserPermissionsUpdateRequested) {
        await _onUpdatePermissions(event, emit);
        return;
      }
      if (event is AdminUserToggleStatusRequested) {
        await _onToggle(event, emit);
        return;
      }
      if (event is AdminUserDeleteRequested) {
        await _onDelete(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  Future<void> _onLoad(
    AdminUsersLoadRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    final result = await _get();
    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }
    _admins = result.getOrElse(() => []);
    emit(AdminUsersLoaded(_admins));
  }

  Future<void> _onCreate(
    AdminUserCreateRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());

    // ✅ Defense-in-depth — re-resolve the role from the final
    // permission set regardless of what role label the caller
    // passed in. This guarantees a hand-edited permission set
    // is always saved as "custom" (or a matching preset), even
    // if this event ever gets dispatched from somewhere that
    // forgot to do this resolution itself.
    final resolvedRole = AdminRole.resolveFromPermissions(e.permissions);

    final result = await _create(
      name: e.name,
      email: e.email,
      password: e.password,
      role: resolvedRole,
      permissions: e.permissions,
    );

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }

    final fresh = await _get();
    _admins = fresh.getOrElse(() => _admins);

    emit(
      AdminUsersActionSuccess(
        message: '${e.name} added as ${resolvedRole.label}',
        admins: _admins,
      ),
    );
  }

  Future<void> _onUpdateRole(
    AdminUserRoleUpdateRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await _updateRole(adminId: e.adminId, newRole: e.newRole);

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }

    _admins = _admins.map((a) {
      if (a.id == e.adminId) {
        return AdminUserModel(
          id: a.id,
          name: a.name,
          email: a.email,
          role: e.newRole,
          permissions: e.newRole.permissions,
          isActive: a.isActive,
          createdAt: a.createdAt,
          lastLogin: a.lastLogin,
        );
      }
      return a;
    }).toList();

    emit(
      AdminUsersActionSuccess(
        message: 'Role updated to ${e.newRole.label}',
        admins: _admins,
      ),
    );
  }

  Future<void> _onUpdatePermissions(
    AdminUserPermissionsUpdateRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    // ✅ Now uses the shared resolver (was inline logic before —
    // consolidated so create & edit flows can never disagree).
    final resolvedRole = AdminRole.resolveFromPermissions(e.permissions);

    final result = await _updatePermissions(
      adminId: e.adminId,
      permissions: e.permissions,
      role: resolvedRole,
    );

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }

    _admins = _admins.map((a) {
      if (a.id == e.adminId) {
        return AdminUserModel(
          id: a.id,
          name: a.name,
          email: a.email,
          role: resolvedRole,
          permissions: e.permissions,
          isActive: a.isActive,
          createdAt: a.createdAt,
          lastLogin: a.lastLogin,
        );
      }
      return a;
    }).toList();

    emit(
      AdminUsersActionSuccess(message: 'Permissions updated', admins: _admins),
    );
  }

  Future<void> _onToggle(
    AdminUserToggleStatusRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await _toggle(adminId: e.adminId, isActive: e.isActive);

    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }

    _admins = _admins.map((a) {
      if (a.id == e.adminId) {
        return AdminUserModel(
          id: a.id,
          name: a.name,
          email: a.email,
          role: a.role,
          permissions: a.permissions,
          isActive: e.isActive,
          createdAt: a.createdAt,
          lastLogin: a.lastLogin,
        );
      }
      return a;
    }).toList();

    emit(
      AdminUsersActionSuccess(
        message: e.isActive ? 'Account enabled' : 'Account disabled',
        admins: _admins,
      ),
    );
  }

  Future<void> _onDelete(
    AdminUserDeleteRequested e,
    Emitter<AdminUsersState> emit,
  ) async {
    final result = await _delete(e.adminId);
    if (emit.isDone) return;

    if (result.isLeft()) {
      emit(
        AdminUsersError(
          message: result.fold((f) => f, (_) => ''),
          admins: _admins,
        ),
      );
      return;
    }

    _admins = _admins.where((a) => a.id != e.adminId).toList();

    emit(AdminUsersActionSuccess(message: 'Admin removed', admins: _admins));
  }
}
