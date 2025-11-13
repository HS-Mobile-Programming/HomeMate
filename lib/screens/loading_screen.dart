import 'package:flutter/material.dart';
import 'login_screen.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 화면의 어느 곳이든 터치하면 실행
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: const Scaffold(
        backgroundColor: Color(0xFFF5F5F5), // 앱 공통 배경색
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rice_bowl, size: 100, color: Colors.green), // 로고 초록색
              SizedBox(height: 20),
              Text(
                "집밥 메이트",
                style: TextStyle(
                  color: Colors.black, // 글자 검은색
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Text(
                "",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}