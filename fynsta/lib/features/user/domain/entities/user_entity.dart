import 'package:equatable/equatable.dart';

// ⭐ FIX: Expanded the entity to include all fields from the GetUser API response
class UserEntity extends Equatable {
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? profilePic;
  final String? gender;
  final String? dob;

  const UserEntity({
    required this.email,
    this.username,
    this.phoneNumber,
    this.profilePic,
    this.gender,
    this.dob,
  });

  @override
  List<Object?> get props =>
      [email, username, phoneNumber, profilePic, gender, dob];
}
