import 'package:equatable/equatable.dart';
import '../../domain/entities/horoscope.dart';

// ⭐ FIX: Expanded the model to match the full API response
class HoroscopeModel extends Equatable {
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

  const HoroscopeModel({
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

  // ⭐ FIX: Updated factory to parse every field from the JSON
  factory HoroscopeModel.fromJson(Map<String, dynamic> json) {
    String joinList(dynamic list) => (list as List<dynamic>? ?? []).join(' ');

    return HoroscopeModel(
      generalPrediction: joinList(json['gnrlhoro']),
      lovePrediction: joinList(json['lovelife']),
      careerPrediction: joinList(json['business_career']),
      studentPrediction: joinList(json['student']),
      whatToDo: joinList(json['whatdo']),
      whatNotToDo: joinList(json['whatnotdo']),
      remedy: joinList(json['remedy']),
      luckyColour: joinList(json['luckyclr']),
      luckyNumber: json['lucky_number']?.toString() ?? 'N/A',
      favourableAspects: json['favourable_aspects'] ?? 'N/A',
    );
  }

  // ⭐ FIX: Updated toEntity to map all new fields correctly
  Horoscope toEntity() {
    return Horoscope(
      generalPrediction: generalPrediction.isNotEmpty
          ? generalPrediction
          : "No prediction available.",
      lovePrediction: lovePrediction.isNotEmpty
          ? lovePrediction
          : "No love prediction available.",
      careerPrediction: careerPrediction.isNotEmpty
          ? careerPrediction
          : "No career prediction available.",
      studentPrediction: studentPrediction.isNotEmpty
          ? studentPrediction
          : "No student prediction available.",
      whatToDo:
          whatToDo.isNotEmpty ? whatToDo : "No specific advice available.",
      whatNotToDo: whatNotToDo.isNotEmpty
          ? whatNotToDo
          : "No specific advice available.",
      remedy: remedy.isNotEmpty ? remedy : "No remedies available.",
      luckyColour: luckyColour,
      luckyNumber: luckyNumber,
      favourableAspects: favourableAspects,
    );
  }

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
        favourableAspects,
      ];
}
