// 앱 시작 시 인증 확인 후 분기
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // 로그인 상태 확인 후 메인 또는 로그인 화면으로 이동
  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (!mounted) return;

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.rice_bowl, size: 100, color: Colors.green),
            SizedBox(height: 20),
            Text(
              '집밥 메이트',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
