import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<Either<String, AdminEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _ds.signIn(email: email, password: password);
      return Right(result);
    } on FirebaseAuthException catch (e) {
      return Left(_mapError(e.code));
    } catch (e) {
      return Left(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<Either<String, AdminEntity?>> getCurrentAdmin() async {
    try {
      final result = await _ds.getCurrentAdmin();
      return Right(result);
    } catch (_) {
      return const Right(null);
    }
  }

  @override
  Future<void> signOut() => _ds.signOut();

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }
}
