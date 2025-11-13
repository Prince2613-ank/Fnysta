import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.email,
    super.username,
    super.phoneNumber,
    super.profilePic,
    super.gender,
    super.dob,
  });

  // ⭐ FIX: Updated fromJson to correctly parse the nested 'user' object from the API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // The API response nests the user data inside a "user" key
    final userData = json['user'] as Map<String, dynamic>? ?? {};

    return UserModel(
      email: userData['email'] ?? '',
      username: userData['username'],
      phoneNumber: userData['phone_number'],
      profilePic: userData['profile_pic'],
      gender: userData['gender'],
      dob: userData['dob'],
    );
  }

  UserEntity toEntity() => UserEntity(
        email: email,
        username: username,
        phoneNumber: phoneNumber,
        profilePic: profilePic,
        gender: gender,
        dob: dob,
      );
}
