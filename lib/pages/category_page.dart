import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ocrcheck_page.dart';
import 'package:dfdf/server/api_service.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<CategoryPage> {
  static const String _uploadUrl = 'http://203.234.62.82:8000/problem/upload_image';

  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  XFile? _selectedImage;
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      _showSnackBar('카테고리 로딩 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _uploadData() async {
    if (_selectedCategory == null || _selectedImage == null) {
      _showSnackBar('카테고리와 이미지를 선택해주세요!');
      return;
    }

    try {
      final imageBytes = await _selectedImage!.readAsBytes();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromBytes(imageBytes, filename: 'image.jpg'),
      });

      final response = await Dio().post(
        _uploadUrl,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode == 200) {
        _showSnackBar('카테고리와 이미지가 성공적으로 업로드되었습니다.');
        print(response.data); // JSON 데이터를 출력
        _navigateToOcrCheckPage(response.data); // response.data만 전달
      } else {
        _showSnackBar('업로드 실패: ${response.data['message']}');
      }
    } catch (e) {
      _showSnackBar('업로드 중 오류가 발생했습니다: $e');
    }
  }

  void _navigateToOcrCheckPage(Map<String, dynamic> responseData) {
    // '$'로 구분된 옵션 문자열을 리스트로 변환
    // List<String> options = responseData['option']
    //     .split('\$') // '$'를 기준으로 분리
    //     .map((e) => e.trim()) // 각 요소의 앞뒤 공백 제거
    //     .where((e) => e.isNotEmpty) // 빈 문자열 제거
    //     .toList();
    //
    // print(options);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OcrCheckPage(
          category: _selectedCategory!,
          image: _selectedImage!,
          question: responseData['problem'], // responseData에서 접근
          option: responseData['option'].toString().split('\$').toList(),
        ),
      ),
    );
  }


  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("문제 등록"),
        backgroundColor: Color(0xFFDFF2DA),
      ),
      body: _isLoading ? _buildLoadingIndicator() : _buildBody(),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCategoryDropdown(),
          SizedBox(height: 20),
          _buildImagePickerButtons(),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _uploadData,
            child: Text("다음"),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: "카테고리",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategory = value),
    );
  }

  Widget _buildImagePickerButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.camera),
          child: Text("카메라"),
        ),
        SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => _pickImage(ImageSource.gallery),
          child: Text("갤러리"),
        ),
      ],
    );
  }
}