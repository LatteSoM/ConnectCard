class UserModel {
  final int id;
  final String? username;
  final String firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? avatarUrl;

  UserModel({
    required this.id,
    this.username,
    required this.firstName,
    this.lastName,
    required this.phoneNumber,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] as int,
      username: json['username'] as String?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
