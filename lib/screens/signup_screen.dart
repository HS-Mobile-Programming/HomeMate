// 회원가입 화면 UI와 상태 관리
import 'package:flutter/material.dart';
import '../services/account_service.dart';
import '../widgets/text_field.dart';
import 'tos_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 이용약관 동의 상태
  bool isAgreed = false;
  // 입력 필드 컨트롤러
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  // 로딩·에러 상태
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    // 화면 종료 시 컨트롤러 자원 정리
    _emailController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 회원가입 버튼 처리 흐름: 약관 확인 → 입력 검증 → 서비스 호출 → 성공 알림 및 복귀
  Future<void> _onSignUpPressed() async {
    if (!isAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("이용약관에 동의해주세요.")));
      return;
    }

    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final confirmPassword = _pwConfirmController.text.trim();
    final nickname = _nameController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        nickname.isEmpty) {
      setState(() {
        _errorText = "모든 필드를 입력해주세요.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorText = "비밀번호가 일치하지 않습니다.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorText = "비밀번호는 6자 이상이어야 합니다.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await AccountService.instance.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("회원가입이 완료되었습니다.")));
      Navigator.pop(context);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "회원가입",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.rice_bowl, size: 80, color: Colors.green),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _emailController,
              hintText: "ID 입력 (이메일)",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _pwController,
              hintText: "PW",
              isObscure: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _pwConfirmController,
              hintText: "PW 확인",
              isObscure: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: _nameController, hintText: "닉네임 입력"),
            const SizedBox(height: 24),
            // 이용약관 동의 영역
            Row(
              children: [
                Checkbox(
                  value: isAgreed,
                  onChanged: (value) {
                    setState(() {
                      isAgreed = value ?? false;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
                const Text(
                  "이용약관에 동의합니다.",
                  style: TextStyle(color: Colors.black),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TosScreen(),
                      ),
                    );
                  },
                  child: const Text("약관 보기"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSignUpPressed,
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
                        "회원가입",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
