import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_user.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();
  @override
  List<Object> get props => [];
}

class FetchUserEvent extends UserEvent {
  final String email;
  const FetchUserEvent({required this.email});
  @override
  List<Object> get props => [email];
}

// States
abstract class UserState extends Equatable {
  const UserState();
  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final UserEntity user;
  const UserLoaded({required this.user});
  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;
  const UserError({required this.message});
  @override
  List<Object> get props => [message];
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final GetUser getUser;

  UserBloc({required this.getUser}) : super(UserInitial()) {
    on<FetchUserEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final user = await getUser(event.email);
        emit(UserLoaded(user: user));
      } catch (e) {
        emit(UserError(message: e.toString()));
      }
    });
  }
}
