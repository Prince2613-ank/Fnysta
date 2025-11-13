import 'package:equatable/equatable.dart';

class CoinEntity extends Equatable {
  final int coins;

  const CoinEntity({required this.coins});

  @override
  List<Object?> get props => [coins];
}
