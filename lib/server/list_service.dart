import 'package:dio/dio.dart';

class ProblemService {
  final Dio _dio = Dio();

  Future<List<Map<String, String>>> fetchProblems() async {
    try {
      final response = await _dio.get(
        'https://your-server-ip/your-api-endpoint', // 서버 API URL
      );

      if (response.statusCode == 200) {
        return List<Map<String, String>>.from(response.data);
      } else {
        throw Exception('문제를 불러오지 못했습니다.');
      }
    } catch (e) {
      throw Exception('문제를 가져오는 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> deleteProblem(String problemId) async {
    try {
      final response = await _dio.delete(
        'https://your-server-ip/your-api-endpoint/$problemId', // 문제 삭제 API URL
      );

      if (response.statusCode != 200) {
        throw Exception('문제를 삭제하지 못했습니다.');
      }
    } catch (e) {
      throw Exception('문제 삭제 중 오류가 발생했습니다: $e');
    }
  }

  Future<void> updateProblem(String problemId, String description) async {
    try {
      final response = await _dio.put(
        'https://your-server-ip/your-api-endpoint/$problemId', // 문제 수정 API URL
        data: {'description': description},
      );

      if (response.statusCode != 200) {
        throw Exception('문제를 수정하지 못했습니다.');
      }
    } catch (e) {
      throw Exception('문제 수정 중 오류가 발생했습니다: $e');
    }
  }
}
