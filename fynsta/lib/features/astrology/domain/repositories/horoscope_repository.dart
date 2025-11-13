import '../entities/horoscope.dart';
import '../../data/datasources/horoscope_remote_data_source.dart';

// Abstract contract for the repository.
abstract class HoroscopeRepository {
  Future<Horoscope> getHoroscope(String zodiacSign, HoroscopeType type);
}
