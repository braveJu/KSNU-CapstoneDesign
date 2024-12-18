import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class TestListPage extends StatefulWidget {
  @override
  _TestListPageState createState() => _TestListPageState();
}

class _TestListPageState extends State<TestListPage> {
  final Dio _dio = Dio();
  List<Map<String, dynamic>> tests = [];
  bool isLoading = true;

  Future<void> _loadTests() async {
    try {
      final response = await _dio.get('http://203.234.62.82:8000/problem/list');
      if (response.statusCode == 200) {
        final List<dynamic> fetchedTests = response.data;
        setState(() {
          tests = fetchedTests.cast<Map<String, dynamic>>();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load tests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("시험 목록을 불러오는 중 오류가 발생했습니다: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("시험 목록"),
          backgroundColor: Color(0xFFDFF2DA),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("시험 목록"),
        backgroundColor: Color(0xFFDFF2DA),
      ),
      body: ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: ListTile(
              title: Text(tests[index]["question"] ?? ""),
              subtitle: Text(
                "날짜: ${tests[index]["date"] ?? "미정"}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                // 시험 상세 페이지로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestDetailPage(
                      testId: tests[index]["id"],
                      title: tests[index]["title"] ?? "",
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TestDetailPage extends StatelessWidget {
  final int testId;
  final String title;

  TestDetailPage({required this.testId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("시험 세부 정보"),
        backgroundColor: Color(0xFFDFF2DA),
      ),
      body: Center(
        child: Text("시험 ID: $testId\n제목: $title"),
      ),
    );
  }
}
