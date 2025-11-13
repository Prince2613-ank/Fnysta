import '../entities/horoscope.dart';
import '../repositories/horoscope_repository.dart';
import '../../data/datasources/horoscope_remote_data_source.dart';

// Connects the BLoC to the repository.
class GetHoroscope {
  final HoroscopeRepository repository;

  GetHoroscope(this.repository);

  Future<Horoscope> call(String zodiacSign, HoroscopeType type) async {
    return await repository.getHoroscope(zodiacSign, type);
  }
}
