import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/admin_user_entity.dart';
import '../../domain/repositories/admin_users_repository.dart';
import '../datasources/admin_users_datasource.dart';

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  final AdminUsersDataSource _ds;
  AdminUsersRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<AdminUserEntity>>> getAdminUsers() async {
    try {
      return Right(await _ds.getAdminUsers());
    } catch (e) {
      return Left('Failed to load admins: $e');
    }
  }

  @override
  Future<Either<String, void>> createAdminUser({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
    required List<String> permissions,
  }) async {
    try {
      await _ds.createAdminUser(
        name: name,
        email: email,
        password: password,
        role: role,
        permissions: permissions,
      );
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e.code));
    } catch (e) {
      return Left('Failed to create admin: $e');
    }
  }

  @override
  Future<Either<String, void>> updateAdminRole({
    required String adminId,
    required AdminRole newRole,
  }) async {
    try {
      await _ds.updateAdminRole(adminId: adminId, newRole: newRole);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update role: $e');
    }
  }

  @override
  Future<Either<String, void>> updateAdminPermissions({
    required String adminId,
    required List<String> permissions,
    required AdminRole role,
  }) async {
    try {
      await _ds.updateAdminPermissions(
        adminId: adminId,
        permissions: permissions,
        role: role,
      );
      return const Right(null);
    } catch (e) {
      return Left('Failed to update permissions: $e');
    }
  }

  @override
  Future<Either<String, void>> toggleAdminStatus({
    required String adminId,
    required bool isActive,
  }) async {
    try {
      await _ds.toggleAdminStatus(adminId: adminId, isActive: isActive);
      return const Right(null);
    } catch (e) {
      return Left('Failed to toggle status: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteAdminUser(String adminId) async {
    try {
      await _ds.deleteAdminUser(adminId);
      return const Right(null);
    } catch (e) {
      return Left('Failed to delete admin: $e');
    }
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Failed to create account';
    }
  }
}
