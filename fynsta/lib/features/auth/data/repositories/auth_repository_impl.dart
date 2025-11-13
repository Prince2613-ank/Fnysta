import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> sendOtp(String email) async {
    try {
      await remoteDataSource.sendOtp(email);
    } on ServerException {
      throw Exception('Failed to send OTP.');
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    try {
      return await remoteDataSource.verifyOtp(email, otp);
    } on ServerException {
      throw Exception('Failed to verify OTP.');
    }
  }
}
