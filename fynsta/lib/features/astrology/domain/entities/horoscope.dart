import 'package:equatable/equatable.dart';

// ⭐ FIX: Added all new fields to the entity
class Horoscope extends Equatable {
  final String generalPrediction;
  final String lovePrediction;
  final String careerPrediction;
  final String studentPrediction;
  final String whatToDo;
  final String whatNotToDo;
  final String remedy;
  final String luckyColour;
  final String luckyNumber;
  final String favourableAspects;

  const Horoscope({
    required this.generalPrediction,
    required this.lovePrediction,
    required this.careerPrediction,
    required this.studentPrediction,
    required this.whatToDo,
    required this.whatNotToDo,
    required this.remedy,
    required this.luckyColour,
    required this.luckyNumber,
    required this.favourableAspects,
  });

  @override
  List<Object?> get props => [
        generalPrediction,
        lovePrediction,
        careerPrediction,
        studentPrediction,
        whatToDo,
        whatNotToDo,
        remedy,
        luckyColour,
        luckyNumber,
        favourableAspects
      ];
}
