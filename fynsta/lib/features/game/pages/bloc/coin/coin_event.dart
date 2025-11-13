import 'package:equatable/equatable.dart';

abstract class CoinEvent extends Equatable {
  const CoinEvent();

  @override
  List<Object> get props => [];
}

class GetCoinEvent extends CoinEvent {
  final String email;

  const GetCoinEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class UpdateCoinBy10Event extends CoinEvent {
  final String email;

  const UpdateCoinBy10Event({required this.email});

  @override
  List<Object> get props => [email];
}
