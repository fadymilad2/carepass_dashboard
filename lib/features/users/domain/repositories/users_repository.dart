import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';

abstract class UsersRepository {
  Future<Either<String, List<UserEntity>>> getUsers();

  Future<Either<String, void>> updateUserStatus({
    required String userId,
    required String status,
  });

  Future<Either<String, void>> extendSubscription({
    required String userId,
    required int days,
  });
}
