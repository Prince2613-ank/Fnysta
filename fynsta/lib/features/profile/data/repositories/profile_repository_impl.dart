import 'package:fynsta/core/error/exceptions.dart';
import 'package:fynsta/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:fynsta/features/profile/data/models/user_update_model.dart';
import 'package:fynsta/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> updateUserProfile(UserUpdateModel userUpdateModel) async {
    try {
      await remoteDataSource.updateUserProfile(userUpdateModel);
    } on ServerException catch (e) {
      throw Exception(e.toString());
    }
  }
}
