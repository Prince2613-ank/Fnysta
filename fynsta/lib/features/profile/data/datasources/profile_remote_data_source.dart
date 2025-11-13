import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fynsta/core/constants.dart';
import 'package:fynsta/core/error/exceptions.dart';
import 'package:fynsta/features/profile/data/models/user_update_model.dart';

abstract class ProfileRemoteDataSource {
  Future<void> updateUserProfile(UserUpdateModel userUpdateModel);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;

  ProfileRemoteDataSourceImpl({required this.client});

  @override
  Future<void> updateUserProfile(UserUpdateModel userUpdateModel) async {
    final uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.updateUser);

    if (kDebugMode) {
      print('--- Updating User Profile ---');
      print('URL: $uri');
      print('Body: ${json.encode(userUpdateModel.toJson())}');
      print('-----------------------------');
    }

    try {
      final response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userUpdateModel.toJson()),
      );

      if (kDebugMode) {
        print('--- Update User Profile Response ---');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('------------------------------------');
      }

      if (response.statusCode != 200) {
        final errorBody = json.decode(response.body);
        final errorMessage = errorBody['detail'] ?? 'Failed to update profile';
        throw ServerException(errorMessage);
      }
    } catch (e) {
      throw ServerException('Failed to connect to the server: $e');
    }
  }
}
