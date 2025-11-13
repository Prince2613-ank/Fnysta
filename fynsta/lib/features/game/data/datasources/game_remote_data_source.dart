import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';

abstract class GameRemoteDataSource {
  Future<int> getCoin(String email);
  Future<void> updateCoinBy10(String email);
}

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final http.Client client;

  GameRemoteDataSourceImpl({required this.client});

  @override
  Future<int> getCoin(String email) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.getCoin}')
        .replace(queryParameters: {'email': email});
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('--- GetCoin Response ---');
        print('URL: $uri');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('------------------------');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['coin'];
      } else {
        throw ServerException('Failed to get coins');
      }
    } catch (e) {
      throw ServerException('An error occurred while fetching coins: $e');
    }
  }

  @override
  Future<void> updateCoinBy10(String email) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.updateCoin}')
        .replace(queryParameters: {'email': email});
    try {
      final response = await client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (kDebugMode) {
        print('--- UpdateCoinBy10 Response ---');
        print('URL: $uri');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        print('-----------------------------');
      }

      if (response.statusCode != 200) {
        throw ServerException('Failed to update coins');
      }
    } catch (e) {
      throw ServerException('An error occurred while updating coins: $e');
    }
  }
}
