import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSentSuccess extends AuthState {
  final String email;
  const AuthCodeSentSuccess({required this.email});
  @override
  List<Object> get props => [email];
}

class AuthLoggedIn extends AuthState {
  final String token;

  const AuthLoggedIn({required this.token});

  @override
  List<Object> get props => [token];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
