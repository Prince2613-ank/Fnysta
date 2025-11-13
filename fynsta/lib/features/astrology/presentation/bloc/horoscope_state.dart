import 'package:equatable/equatable.dart';
import '../../domain/entities/horoscope.dart';

abstract class HoroscopeState extends Equatable {
  const HoroscopeState();

  @override
  List<Object> get props => [];
}

class HoroscopeInitial extends HoroscopeState {}

class HoroscopeLoading extends HoroscopeState {}

class HoroscopeLoaded extends HoroscopeState {
  final Horoscope horoscope;

  const HoroscopeLoaded({required this.horoscope});

  @override
  List<Object> get props => [horoscope];
}

class HoroscopeError extends HoroscopeState {
  final String message;

  const HoroscopeError({required this.message});

  @override
  List<Object> get props => [message];
}
