import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<String> call(String email, String otp) async {
    return await repository.verifyOtp(email, otp);
  }
}
