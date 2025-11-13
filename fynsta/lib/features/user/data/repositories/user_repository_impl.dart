import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> getUser(String email) async {
    try {
      final userModel = await remoteDataSource.getUser(email);
      return userModel.toEntity();
    } on ServerException catch (e) {
      throw Exception(e.toString());
    }
  }
}
