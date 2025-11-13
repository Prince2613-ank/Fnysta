import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fynsta/features/game/domain/usecases/get_coin.dart';
import 'package:fynsta/features/game/domain/usecases/update_coin.dart';
import 'coin_event.dart';
import 'coin_state.dart';

class CoinBloc extends Bloc<CoinEvent, CoinState> {
  final GetCoin getCoin;
  final UpdateCoinBy10 updateCoinBy10;

  CoinBloc({required this.getCoin, required this.updateCoinBy10})
      : super(CoinInitial()) {
    on<GetCoinEvent>((event, emit) async {
      emit(CoinLoading());
      try {
        final coins = await getCoin(event.email);
        emit(CoinLoaded(coins: coins));
      } catch (e) {
        emit(CoinError(message: e.toString()));
      }
    });
    on<UpdateCoinBy10Event>((event, emit) async {
      try {
        await updateCoinBy10(event.email);
        final coins = await getCoin(event.email);
        emit(CoinLoaded(coins: coins));
      } catch (e) {
        emit(CoinError(message: e.toString()));
      }
    });
  }
}
