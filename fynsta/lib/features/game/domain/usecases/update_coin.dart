import 'package:fynsta/features/game/domain/repositories/coin_repository.dart';

class UpdateCoinBy10 {
  final CoinRepository repository;

  UpdateCoinBy10(this.repository);

  Future<void> call(String email) async {
    await repository.updateCoinBy10(email);
  }
}
