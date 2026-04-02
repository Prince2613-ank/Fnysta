import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUser(String email);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;

  UserRemoteDataSourceImpl({required this.client});

  @override
  Future<UserModel> getUser(String email) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/user/get-user/')
        .replace(queryParameters: {'email': email});

    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      // ⭐ FIX: Added print statements for debugging the response
      if (kDebugMode) {
        print('--- GetUser Response ---');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('------------------------');
      }

      if (response.statusCode == 200) {
        return UserModel.fromJson(json.decode(response.body));
      } else {
        // Provide a more specific error message
        throw ServerException(
            'Failed to fetch user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch network or parsing errors
      if (kDebugMode) {
        print('--- GetUser Error ---');
        print('Exception: $e');
        print('---------------------');
      }
      throw ServerException('An error occurred while fetching user data: $e');
    }
  }
}
