import 'package:dio/dio.dart';

class QuestionService {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchQuestions() async {
    try {
      final response = await _dio.get(
        'https://your-server-ip/your-api-endpoint', // 서버 API URL 입력
      );

      if (response.statusCode == 200) {
        return response.data; // 서버에서 받아온 문제 데이터 반환
      } else {
        throw Exception('문제를 불러오지 못했습니다.');
      }
    } catch (e) {
      throw Exception('문제를 가져오는 중 오류가 발생했습니다: $e');
    }
  }
}
