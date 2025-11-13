import 'package:fynsta/features/game/domain/repositories/coin_repository.dart';

class GetCoin {
  final CoinRepository repository;

  GetCoin(this.repository);

  Future<int> call(String email) async {
    return await repository.getCoin(email);
  }
}
