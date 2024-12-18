import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'category_page.dart';
import 'solve_page.dart';
import 'list_page.dart';

void main() {
  runApp(MaterialApp(
    home: MainPage(),
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String name = "오인핑";

  // 버튼을 생성하는 메서드
  Widget _buildButton(String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFFA0D5AA),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFDFF2DA),
      appBar: AppBar(
        backgroundColor: Color(0xFFDFF2DA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF86C37E)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF86C37E)),
            onPressed: () {
              print("메뉴 클릭");
            },
          ),
        ],
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
                const SizedBox(height: 20),
                Container(
                  width: 100,
                  height: 100,
                  child: SvgPicture.asset(
                    'assets/solve1.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                  '$name 님, 안녕하세요!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildButton("문제 등록", CategoryPage()),
                      _buildButton("문제 풀기", const SolvePage()),
                      _buildButton("문제 목록", TestListPage()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => print("홈 클릭"),
              icon: Icon(Icons.home, color: Color(0xFF86C37E)),
            ),
            IconButton(
              onPressed: () => print("커뮤니티 클릭"),
              icon: Icon(Icons.chat_bubble_outline, color: Color(0xFF86C37E)),
            ),
            IconButton(
              onPressed: () => print("프로필 클릭"),
              icon: Icon(Icons.person_outline, color: Color(0xFF86C37E)),
            ),
          ],
        ),
      ),
    );
  }
}
