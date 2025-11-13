import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fynsta/features/profile/domain/usecases/update_user_profile.dart';
import 'package:fynsta/features/profile/presentation/bloc/profile_event.dart';
import 'package:fynsta/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateUserProfile updateUserProfile;

  ProfileBloc({required this.updateUserProfile}) : super(ProfileInitial()) {
    on<UpdateProfileEvent>((event, emit) async {
      emit(ProfileLoading());
      try {
        await updateUserProfile(event.userUpdateModel);
        emit(ProfileUpdateSuccess());
      } catch (e) {
        emit(ProfileError(message: e.toString()));
      }
    });
  }
}
