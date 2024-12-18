import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiService.post('ip/user/login', {
        'username': email,
        'password': password,
      },);
      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        throw Exception(response.data['message']);
      }
    } catch (e) {
      throw Exception('로그인 실패: $e');
    }
  }
}
