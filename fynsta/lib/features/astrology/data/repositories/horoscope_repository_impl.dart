import 'package:fynsta/core/error/exceptions.dart';

import '../../domain/entities/horoscope.dart';
import '../../domain/repositories/horoscope_repository.dart';
import '../datasources/horoscope_remote_data_source.dart';

class HoroscopeRepositoryImpl implements HoroscopeRepository {
  final HoroscopeRemoteDataSource remoteDataSource;

  HoroscopeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Horoscope> getHoroscope(String zodiacSign, HoroscopeType type) async {
    try {
      final horoscopeModel =
          await remoteDataSource.getHoroscope(zodiacSign, type);
      return horoscopeModel.toEntity();
    } on ServerException {
      // In a real app, you would handle this more gracefully (e.g., using Either<Failure, Horoscope>)
      // For now, we'll rethrow a domain-level exception or return a default object.
      throw Exception('Failed to fetch data from the server.');
    }
  }
}
