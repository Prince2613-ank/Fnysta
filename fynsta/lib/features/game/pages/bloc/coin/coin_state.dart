import 'package:equatable/equatable.dart';

abstract class CoinState extends Equatable {
  const CoinState();

  @override
  List<Object> get props => [];
}

class CoinInitial extends CoinState {}

class CoinLoading extends CoinState {}

class CoinLoaded extends CoinState {
  final int coins;

  const CoinLoaded({required this.coins});

  @override
  List<Object> get props => [coins];
}

class CoinError extends CoinState {
  final String message;

  const CoinError({required this.message});

  @override
  List<Object> get props => [message];
}
