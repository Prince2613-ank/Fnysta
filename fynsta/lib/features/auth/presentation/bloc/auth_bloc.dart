import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;

  AuthBloc({required this.sendOtp, required this.verifyOtp})
      : super(AuthInitial()) {
    on<SendOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        await sendOtp(event.email);
        emit(AuthCodeSentSuccess(email: event.email));
      } catch (e) {
        // ⭐ FIX: Pass the detailed exception message to the UI
        emit(AuthError(message: e.toString()));
      }
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(AuthLoading());
      try {
        final token = await verifyOtp(event.email, event.otp);
        emit(AuthLoggedIn(token: token));
      } catch (e) {
        // ⭐ FIX: Pass the detailed exception message to the UI
        emit(AuthError(message: e.toString()));
      }
    });
  }
}
