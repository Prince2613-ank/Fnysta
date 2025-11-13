import 'package:fynsta/features/auth/domain/repositories/auth_repository.dart';

class SendOtp {
  final AuthRepository repository;

  SendOtp(this.repository);

  Future<void> call(String email) async {
    await repository.sendOtp(email);
  }
}
