import 'package:fynsta/core/error/exceptions.dart';
import 'package:fynsta/features/game/data/datasources/game_remote_data_source.dart';
import 'package:fynsta/features/game/domain/repositories/coin_repository.dart';

class CoinRepositoryImpl implements CoinRepository {
  final GameRemoteDataSource remoteDataSource;

  CoinRepositoryImpl({required this.remoteDataSource});

  @override
  Future<int> getCoin(String email) async {
    try {
      return await remoteDataSource.getCoin(email);
    } on ServerException {
      throw Exception('Failed to get coins.');
    }
  }

  @override
  Future<void> updateCoinBy10(String email) async {
    try {
      await remoteDataSource.updateCoinBy10(email);
    } on ServerException {
      throw Exception('Failed to update coins.');
    }
  }
}
