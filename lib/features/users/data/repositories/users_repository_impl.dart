import 'package:dartz/dartz.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_datasource.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersDataSource _ds;
  UsersRepositoryImpl(this._ds);

  @override
  Future<Either<String, List<UserEntity>>> getUsers() async {
    try {
      return Right(await _ds.getUsers());
    } catch (e) {
      return Left('Failed to load users: $e');
    }
  }

  @override
  Future<Either<String, void>> updateUserStatus({
    required String userId,
    required String status,
  }) async {
    try {
      await _ds.updateUserStatus(userId: userId, status: status);
      return const Right(null);
    } catch (e) {
      return Left('Failed to update status: $e');
    }
  }

  @override
  Future<Either<String, void>> extendSubscription({
    required String userId,
    required int days,
  }) async {
    try {
      await _ds.extendSubscription(userId: userId, days: days);
      return const Right(null);
    } catch (e) {
      return Left('Failed to extend subscription: $e');
    }
  }
}
