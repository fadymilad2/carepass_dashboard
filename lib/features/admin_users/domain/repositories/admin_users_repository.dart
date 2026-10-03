import 'package:dartz/dartz.dart';
import '../entities/admin_user_entity.dart';

abstract class AdminUsersRepository {
  Future<Either<String, List<AdminUserEntity>>> getAdminUsers();

  Future<Either<String, void>> createAdminUser({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
    required List<String> permissions,
  });

  Future<Either<String, void>> updateAdminRole({
    required String adminId,
    required AdminRole newRole,
  });

  Future<Either<String, void>> updateAdminPermissions({
    required String adminId,
    required List<String> permissions,
    required AdminRole role,
  });

  Future<Either<String, void>> toggleAdminStatus({
    required String adminId,
    required bool isActive,
  });

  Future<Either<String, void>> deleteAdminUser(String adminId);
}
