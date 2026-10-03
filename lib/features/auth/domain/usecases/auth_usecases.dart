import 'package:dartz/dartz.dart';
import '../entities/admin_entity.dart';
import '../repositories/auth_repository.dart';

class SignInAdmin {
  final AuthRepository repo;
  SignInAdmin(this.repo);

  Future<Either<String, AdminEntity>> call({
    required String email,
    required String password,
  }) => repo.signIn(email: email, password: password);
}

class GetCurrentAdmin {
  final AuthRepository repo;
  GetCurrentAdmin(this.repo);

  Future<Either<String, AdminEntity?>> call() => repo.getCurrentAdmin();
}

class SignOutAdmin {
  final AuthRepository repo;
  SignOutAdmin(this.repo);

  Future<void> call() => repo.signOut();
}
