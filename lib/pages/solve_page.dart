import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class SolvePage extends StatefulWidget {
  const SolvePage({Key? key}) : super(key: key);

  @override
  State<SolvePage> createState() => _SolvePageState();
}

class _SolvePageState extends State<SolvePage> with SingleTickerProviderStateMixin {
  final Dio _dio = Dio();
  int currentQuestionIndex = 0;
  List<dynamic> questions = [];
  bool isLoading = true;
  bool showCorrectAnimation = false; // 정답 애니메이션 표시 여부
  bool showIncorrectAnimation = false; // 틀렸다고 표시할 애니메이션 여부
  late AnimationController _animationController; // 애니메이션 컨트롤러

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // 애니메이션 지속 시간
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await _dio.get('ip/problem/list');
      if (response.statusCode == 200) {
        setState(() {
          questions = response.data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar("문제를 불러오는 중 오류가 발생했습니다: $e");
    }
  }

  void _onAnswerSelected(bool isCorrect) async {
    setState(() {
      if (isCorrect) {
        showCorrectAnimation = true; // 애니메이션 활성화
      } else {
        showIncorrectAnimation = true; // 애니메이션 활성화
      }
    });

    // 애니메이션 실행
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() {
        showCorrectAnimation = false; // 애니메이션 비활성화
        showIncorrectAnimation = false; // 애니메이션 비활성화
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("모든 문제를 풀이했습니다.")),
          );
        }
      });
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          if (isLoading) _buildLoadingScreen(),
          if (!isLoading && questions.isEmpty) _buildEmptyQuestionScreen(),
          if (!isLoading && questions.isNotEmpty) _buildQuestionScreen(),
          if (showCorrectAnimation) _buildCorrectAnimation(), // 정답 애니메이션
          if (showIncorrectAnimation) _buildIncorrectAnimation(), // 틀렸다고 애니메이션
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "문제 풀기",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.teal),
    );
  }

  Widget _buildEmptyQuestionScreen() {
    return const Center(
      child: Text(
        "문제가 없습니다.",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildQuestionScreen() {
    final currentQuestion = questions[currentQuestionIndex];
    final options = currentQuestion['option'].toString().split('\$').toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            _buildQuestionInfo(),
            const SizedBox(height: 20),
            _buildQuestionText(currentQuestion),
            const SizedBox(height: 40),
            _buildInstructionText(),
            const SizedBox(height: 20),
            _buildAnswerOptions(options),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInfo() {
    return Text(
      "문제 ${currentQuestionIndex + 1} / ${questions.length}",
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildQuestionText(Map<String, dynamic> currentQuestion) {
    return Text(
      currentQuestion['question'] ?? "문제 내용이 없습니다.",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      "아래 보기 중에서 정답을 선택하세요:",
      style: TextStyle(fontSize: 16, color: Colors.black),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAnswerOptions(List<String> options) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final isCorrect = questions[currentQuestionIndex]['answer'].toString() == (index+1).toString();
            print(questions[currentQuestionIndex]['answer']);
            print(index.toString());
            print(isCorrect);

            _onAnswerSelected(isCorrect);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                options[index],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCorrectAnimation() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
        ),
        child: Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIncorrectAnimation() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
        ),
        child: Container(
          width: 150,
          height: 150,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 80,
            ),
          ),
        ),
      ),
    );
  }
}
