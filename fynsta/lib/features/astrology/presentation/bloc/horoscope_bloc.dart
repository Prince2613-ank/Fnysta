import 'package:flutter_bloc/flutter_bloc.dart';
import 'horoscope_event.dart';
import 'horoscope_state.dart';
import '../../domain/usecases/get_horoscope.dart';

class HoroscopeBloc extends Bloc<HoroscopeEvent, HoroscopeState> {
  final GetHoroscope getHoroscope;

  HoroscopeBloc({required this.getHoroscope}) : super(HoroscopeInitial()) {
    on<FetchHoroscope>((event, emit) async {
      emit(HoroscopeLoading());
      try {
        final horoscope = await getHoroscope(event.zodiacSign, event.type);
        emit(HoroscopeLoaded(horoscope: horoscope));
      } catch (e) {
        emit(HoroscopeError(
            message: 'Failed to fetch horoscope data. Please try again.'));
      }
    });
  }
}
