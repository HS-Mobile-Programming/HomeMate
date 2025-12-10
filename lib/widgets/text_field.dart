// 커스텀 텍스트 입력 필드: 로그인 및 회원가입 화면용 통일된 스타일의 입력 필드 위젯
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  // 입력 텍스트 제어 컨트롤러
  final TextEditingController controller;
  // 입력 필드 힌트 텍스트
  final String hintText;
  // 비밀번호 가림 여부
  final bool isObscure;
  // 키보드 타입 (이메일, 숫자 등)
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.isObscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
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
