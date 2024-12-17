import '../user/user_model.dart';

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({required this.token, required this.user});
}
