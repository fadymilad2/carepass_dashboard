import '../../../../core/utils/sequential_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── Events ────────────────────────────────────────────────────────────
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInAdmin _signIn;
  final GetCurrentAdmin _getAdmin;
  final SignOutAdmin _signOut;

  AuthBloc({
    required SignInAdmin signIn,
    required GetCurrentAdmin getAdmin,
    required SignOutAdmin signOut,
  }) : _signIn = signIn,
       _getAdmin = getAdmin,
       _signOut = signOut,
       super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is AuthCheckRequested) {
        await _onCheck(event, emit);
        return;
      }
      if (event is AuthSignInRequested) {
        await _onSignIn(event, emit);
        return;
      }
      if (event is AuthSignOutRequested) {
        await _onSignOut(event, emit);
        return;
      }
    }, transformer: sequentialEvents());
  }

  Future<void> _onCheck(AuthCheckRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _getAdmin();

    if (result.isLeft()) {
      emit(AuthUnauthenticated());
      return;
    }

    final admin = result.getOrElse(() => null);
    if (admin == null) {
      emit(AuthUnauthenticated());
    } else {
      emit(AuthAuthenticated(admin));
    }
  }

  Future<void> _onSignIn(AuthSignInRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _signIn(email: e.email, password: e.password);

    if (result.isLeft()) {
      emit(AuthError(result.fold((f) => f, (_) => '')));
      return;
    }

    emit(AuthAuthenticated(result.getOrElse(() => throw Exception())));
  }

  Future<void> _onSignOut(
    AuthSignOutRequested e,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _signOut();
      if (!emit.isDone) emit(AuthUnauthenticated());
    } catch (_) {
      if (!emit.isDone) {
        emit(const AuthError('Sign out failed. Please try again.'));
      }
    }
  }
}
