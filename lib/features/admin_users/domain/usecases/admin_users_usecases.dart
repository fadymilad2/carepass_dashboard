import 'package:dartz/dartz.dart';
import '../entities/admin_user_entity.dart';
import '../repositories/admin_users_repository.dart';

class GetAdminUsers {
  final AdminUsersRepository repo;
  GetAdminUsers(this.repo);
  Future<Either<String, List<AdminUserEntity>>> call() => repo.getAdminUsers();
}

class CreateAdminUser {
  final AdminUsersRepository repo;
  CreateAdminUser(this.repo);

  Future<Either<String, void>> call({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
    required List<String> permissions,
  }) => repo.createAdminUser(
    name: name,
    email: email,
    password: password,
    role: role,
    permissions: permissions,
  );
}

class UpdateAdminRole {
  final AdminUsersRepository repo;
  UpdateAdminRole(this.repo);

  Future<Either<String, void>> call({
    required String adminId,
    required AdminRole newRole,
  }) => repo.updateAdminRole(adminId: adminId, newRole: newRole);
}

class UpdateAdminPermissions {
  final AdminUsersRepository repo;
  UpdateAdminPermissions(this.repo);

  Future<Either<String, void>> call({
    required String adminId,
    required List<String> permissions,
    required AdminRole role,
  }) => repo.updateAdminPermissions(
    adminId: adminId,
    permissions: permissions,
    role: role,
  );
}

class ToggleAdminStatus {
  final AdminUsersRepository repo;
  ToggleAdminStatus(this.repo);

  Future<Either<String, void>> call({
    required String adminId,
    required bool isActive,
  }) => repo.toggleAdminStatus(adminId: adminId, isActive: isActive);
}

class DeleteAdminUser {
  final AdminUsersRepository repo;
  DeleteAdminUser(this.repo);
  Future<Either<String, void>> call(String id) => repo.deleteAdminUser(id);
}
