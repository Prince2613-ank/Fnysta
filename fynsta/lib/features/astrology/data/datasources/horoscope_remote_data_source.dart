import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/horoscope_model.dart';

// ⭐ FIX: Added 'yearly' to the enum
enum HoroscopeType { daily, weekly, monthly, yearly }

abstract class HoroscopeRemoteDataSource {
  Future<HoroscopeModel> getHoroscope(String zodiacSign, HoroscopeType type);
}

class HoroscopeRemoteDataSourceImpl implements HoroscopeRemoteDataSource {
  final http.Client client;

  HoroscopeRemoteDataSourceImpl({required this.client});

  @override
  Future<HoroscopeModel> getHoroscope(
      String zodiacSign, HoroscopeType type) async {
    final String endpoint = _getEndpointForType(type);
    final response = await client.post(
      Uri.parse(ApiConstants.baseUrl + endpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'zodiac_sign': zodiacSign.toLowerCase()}),
    );

    if (kDebugMode) {
      print('API Endpoint: $endpoint');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }

    if (response.statusCode == 200) {
      return HoroscopeModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  String _getEndpointForType(HoroscopeType type) {
    switch (type) {
      case HoroscopeType.daily:
        return ApiConstants.dailyHoroscope;
      case HoroscopeType.weekly:
        return ApiConstants.weeklyHoroscope;
      case HoroscopeType.monthly:
        return ApiConstants.monthlyHoroscope;
      // ⭐ FIX: Added case to handle the new yearly endpoint
      case HoroscopeType.yearly:
        return ApiConstants.yearlyHoroscope;
    }
  }
}
