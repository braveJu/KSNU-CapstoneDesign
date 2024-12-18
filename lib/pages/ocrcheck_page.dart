import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'list_page.dart';
import 'package:dfdf/server/api_service.dart';

class OcrCheckPage extends StatefulWidget {
  final String category;
  final XFile image;
  final String question;
  final List<String> option;

  const OcrCheckPage({
    Key? key,
    required this.category,
    required this.image,
    required this.question,
    required this.option,
  }) : super(key: key);

  @override
  _OcrCheckPageState createState() => _OcrCheckPageState();
}

class _OcrCheckPageState extends State<OcrCheckPage> with SingleTickerProviderStateMixin {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _answerController;
  late Future<Uint8List> _imageFuture;
  final ApiService _apiService = ApiService();
  bool _showCorrectAnimation = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _imageFuture = widget.image.readAsBytes();
    _initAnimationController();
  }

  void _initControllers() {
    _questionController = TextEditingController(text: widget.question);
    _optionControllers = List.generate(
      5,
          (index) => TextEditingController(
        text: widget.option.length > index ? widget.option[index] : '',
      ),
    );
    _answerController = TextEditingController();
  }

  void _initAnimationController() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    _answerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _registerToServer() async {
    try {
      final answer = int.tryParse(_answerController.text);
      if (answer == null || answer < 1 || answer > 5) {
        throw Exception('유효한 정답을 입력해주세요 (1-5)');
      }

      final data = {
        "category": widget.category,
        "problem": _questionController.text,
        "options": _optionControllers.map((controller) => controller.text).toList(),
        "answer": answer,
      };

      final response = await _apiService.post('ip/problem', data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessAnimation();
      } else {
        throw Exception('등록 실패');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showSuccessAnimation() {
    setState(() => _showCorrectAnimation = true);
    _animationController.forward().then((_) {
      _animationController.reset();
      setState(() => _showCorrectAnimation = false);
      _navigateToListPage();
    });
    _showSuccessSnackBar();
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("DB에 저장되었습니다!"),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToListPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  TestListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OCR 확인"),
        elevation: 0,
      ),
      body: FutureBuilder<Uint8List>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("이미지를 불러올 수 없습니다."));
          }
          return _buildBody(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildBody(Uint8List imageBytes) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryChip(),
              const SizedBox(height: 16),
              _buildImagePreview(imageBytes),
              const SizedBox(height: 24),
              _buildQuestionField(),
              const SizedBox(height: 16),
              ..._buildOptionFields(),
              const SizedBox(height: 16),
              _buildAnswerField(),
              const SizedBox(height: 24),
              _buildRegisterButton(),
            ],
          ),
        ),
        if (_showCorrectAnimation) _buildCorrectAnimation(),
      ],
    );
  }

  Widget _buildCategoryChip() {
    return Chip(
      label: Text(
        widget.category,
        style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondary,
    );
  }

  Widget _buildImagePreview(Uint8List imageBytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.memory(
        imageBytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildQuestionField() {
    return _buildTextField("질문", _questionController);
  }

  List<Widget> _buildOptionFields() {
    return _optionControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildTextField("옵션 ${index + 1}", controller),
      );
    }).toList();
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildAnswerField() {
    return TextFormField(
      controller: _answerController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "정답 (1-5)",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '정답을 입력해주세요';
        }
        int? answer = int.tryParse(value);
        if (answer == null || answer < 1 || answer > 5) {
          return '유효한 정답을 입력해주세요 (1-5)';
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _registerToServer,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text("등록", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildCorrectAnimation() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
        ),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 60,
          ),
        ),
      ),
    );
  }
}