import 'package:flutter/material.dart';
import 'tos_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 검은색
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("회원가입", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.rice_bowl, size: 80, color: Colors.green),
            const SizedBox(height: 32),

            _buildTextField("ID 입력 (이메일)"),
            const SizedBox(height: 16),
            _buildTextField("비밀번호 입력", isObscure: true),
            const SizedBox(height: 16),
            _buildTextField("비밀번호 확인", isObscure: true),
            const SizedBox(height: 16),
            _buildTextField("이름 (닉네임)"),

            const SizedBox(height: 24),

            // 이용약관 체크박스
            Row(
              children: [
                Checkbox(
                  value: isAgreed,
                  onChanged: (value) {
                    setState(() {
                      isAgreed = value!;
                    });
                  },
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                ),
                const Text("이용약관에 동의합니다.", style: TextStyle(color: Colors.black)),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TosScreen()),
                    );
                  },
                  child: const Text(
                    "약관 보기 >",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // 가입 완료 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!isAgreed) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("이용약관에 동의해주세요.")),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("회원가입이 완료되었습니다.")),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("회원가입 완료", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool isObscure = false}) {
    return TextField(
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}