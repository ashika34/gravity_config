class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final UserModel user;
  final String token;
  final String tokenType;

  LoginResponse({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
      tokenType: data['token_type'] as String,
    );
  }
}
