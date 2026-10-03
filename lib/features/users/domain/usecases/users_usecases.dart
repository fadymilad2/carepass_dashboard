import 'package:dartz/dartz.dart';
import '../entities/user_entity.dart';
import '../repositories/users_repository.dart';

class GetUsers {
  final UsersRepository repo;
  GetUsers(this.repo);
  Future<Either<String, List<UserEntity>>> call() => repo.getUsers();
}

class UpdateUserStatus {
  final UsersRepository repo;
  UpdateUserStatus(this.repo);
  Future<Either<String, void>> call({
    required String userId,
    required String status,
  }) => repo.updateUserStatus(userId: userId, status: status);
}

class ExtendSubscription {
  final UsersRepository repo;
  ExtendSubscription(this.repo);
  Future<Either<String, void>> call({
    required String userId,
    required int days,
  }) => repo.extendSubscription(userId: userId, days: days);
}
