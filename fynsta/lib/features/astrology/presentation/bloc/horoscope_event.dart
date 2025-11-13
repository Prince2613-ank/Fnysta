import 'package:equatable/equatable.dart';
import '../../data/datasources/horoscope_remote_data_source.dart';

abstract class HoroscopeEvent extends Equatable {
  const HoroscopeEvent();

  @override
  List<Object> get props => [];
}

class FetchHoroscope extends HoroscopeEvent {
  final String zodiacSign;
  final HoroscopeType type;

  const FetchHoroscope({required this.zodiacSign, required this.type});

  @override
  List<Object> get props => [zodiacSign, type];
}
