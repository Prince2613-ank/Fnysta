import 'package:fynsta/features/profile/data/models/user_update_model.dart';

abstract class ProfileRepository {
  Future<void> updateUserProfile(UserUpdateModel userUpdateModel);
}
