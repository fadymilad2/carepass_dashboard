import 'package:dartz/dartz.dart';
import '../entities/admin_entity.dart';

abstract class AuthRepository {
  Future<Either<String, AdminEntity>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, AdminEntity?>> getCurrentAdmin();
  Future<void> signOut();
}
