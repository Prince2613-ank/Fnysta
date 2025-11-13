abstract class CoinRepository {
  Future<int> getCoin(String email);
  Future<void> updateCoinBy10(String email);
}
