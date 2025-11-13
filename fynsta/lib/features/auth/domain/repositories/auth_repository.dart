abstract class AuthRepository {
  Future<void> sendOtp(String email);
  Future<String> verifyOtp(String email, String otp);
}
