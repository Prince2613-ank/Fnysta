import 'package:equatable/equatable.dart';
import 'package:fynsta/features/profile/data/models/user_update_model.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class UpdateProfileEvent extends ProfileEvent {
  final UserUpdateModel userUpdateModel;

  const UpdateProfileEvent({required this.userUpdateModel});

  @override
  List<Object> get props => [userUpdateModel];
}
