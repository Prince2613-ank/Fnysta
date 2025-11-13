import 'package:fynsta/features/user/domain/entities/user_entity.dart';

class UserUpdateModel {
  final String email;
  final String? username;
  final String? phoneNumber;
  final String? profilePic;
  final String? gender;
  final String? dob;

  UserUpdateModel({
    required this.email,
    this.username,
    this.phoneNumber,
    this.profilePic,
    this.gender,
    this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'phone_number': phoneNumber,
      'profile_pic': profilePic,
      'gender': gender,
      'dob': dob,
    };
  }
}
