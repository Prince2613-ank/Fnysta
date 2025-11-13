import 'package:fynsta/features/profile/data/models/user_update_model.dart';
import 'package:fynsta/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile {
  final ProfileRepository repository;

  UpdateUserProfile(this.repository);

  Future<void> call(UserUpdateModel userUpdateModel) async {
    return await repository.updateUserProfile(userUpdateModel);
  }
}
