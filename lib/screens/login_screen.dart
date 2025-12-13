// 로그인 화면 UI·입력 검증·네비게이션
import 'package:flutter/material.dart';

import '../main_screen.dart';
import '../services/account_service.dart';
import '../widgets/text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 이메일 입력 컨트롤러
  final TextEditingController _idController = TextEditingController();
  // 비밀번호 입력 컨트롤러
  final TextEditingController _pwController = TextEditingController();
  // 로딩 상태
  bool _isLoading = false;
  // 에러 메시지
  String? _errorText;

  @override
  void dispose() {
    // 화면 종료 시 컨트롤러 자원 정리
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  // 로그인 처리: 입력 검증 → 서비스 호출 → 성공 시 메인 이동
  Future<void> _onLoginPressed() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = "ID(이메일)와 비밀번호를 모두 입력해주세요.";
      });
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+'); //@와 .을 포함한 이메일 형식 확인
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _errorText = "이메일 형식이 올바르지 않습니다.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await AccountService.instance.signIn(email: email, password: password);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.rice_bowl, size: 120, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              '집밥 메이트',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            // 이메일 입력
            CustomTextField(
              controller: _idController,
              hintText: 'ID (이메일)',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // 비밀번호 입력
            CustomTextField(
              controller: _pwController,
              hintText: 'PW',
              isObscure: true,
            ),
            const SizedBox(height: 32),
            // 에러 메시지 표시
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),
            // 회원가입 / 로그인 버튼 영역
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '회원가입',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '로그인',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}