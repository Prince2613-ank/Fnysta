import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String email);
  Future<String> verifyOtp(String email, String otp);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<void> sendOtp(String email) async {
    final uri = Uri.parse(ApiConstants.baseUrl + '/api/auth/send-otp2/');

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['message'] ?? 'Failed to send OTP';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      // This will catch network errors or if the server is down
      throw ServerException('Failed to connect to the server: $e');
    }
  }

  @override
  Future<String> verifyOtp(String email, String otp) async {
    final response = await client.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.verifyOtp),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['token'];
    } else {
      final errorBody = json.decode(response.body);
      final errorMessage = errorBody['message'] ?? 'Failed to verify OTP';
      throw ServerException(errorMessage);
    }
  }
}
