import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dfdf/server/auth_service.dart';
import 'main_page.dart';

class LoginPage extends StatelessWidget {
  final AuthService _authService = AuthService(); // 서비스 호출
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(BuildContext context) async {
    try {
      String token = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      print("로그인 성공! 토큰: $token");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
        backgroundColor: Color(0xFFDFF2DA),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 배경 이미지
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 30),
                Container(
                  width: 100,
                  height: 100,
                  child: SvgPicture.asset('assets/solve1.svg'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: "이메일"),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "비밀번호"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _handleLogin(context);
                  },
                  child: Text("로그인"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
