// [SCREEN CLASS] - StatelessWidget
// '로그인' 화면 UI를 정의합니다.
// (Stateless: ID/PW 입력은 TextField가 자체 관리하므로, 화면 자체는 상태 변경이 없음)
// 실제 구현은 로그인 처리 상태(로딩, 에러 메시지)를 관리하기 위해 StatefulWidget으로 변경했습니다.

import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../main_screen.dart';
import '../services/account_service.dart';

// StatelessWidget → StatefulWidget 수정
class LoginScreen extends StatefulWidget {
  // const LoginScreen(...): 위젯 생성자
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// [SCREEN CLASS] - StatefulWidget
class _LoginScreenState extends State<LoginScreen> {
  // ID(이메일), PW 입력값을 읽기 위한 컨트롤러입니다.
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  // 로그인 시 로딩 상태 및 에러 메시지를 관리하기 위한 상태 변수입니다.
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    // 화면이 dispose될 때 컨트롤러도 함께 정리합니다.
    _idController.dispose();
    _pwController.dispose();
    super.dispose();
  }

  // 로그인 버튼을 눌렀을 때 실행되는 메서드입니다.
  // 1) 입력값 검증 → 2) AccountService를 이용한 Firebase Auth 로그인 → 3) 성공 시 MainScreen으로 이동
  Future<void> _onLoginPressed() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorText = 'ID(이메일)와 비밀번호를 모두 입력해주세요.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // AccountService를 통해 FirebaseAuth 이메일/비밀번호 로그인을 호출합니다.
      await AccountService.instance.signIn(
        email: email,
        password: password,
      );

      // 로그인 성공 → MainScreen으로 이동 (기존 네비게이션 로직 재사용)
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
      );
    } catch (e) {
      // 로그인 실패 시 에러 메시지를 화면에 표시
      setState(() {
        _errorText = '로그인에 실패했습니다: $e';
      });
    } finally {
      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 밝은 배경

      // SingleChildScrollView: 자식 위젯(Column)의 내용이 화면보다 길어질 경우
      // (예: 키보드가 올라올 때) 스크롤이 가능하도록 만듭니다.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0), // 화면 바깥쪽 여백
        child: Column( // 위젯들을 세로(수직)로 배치
          children: [
            const SizedBox(height: 80), // 화면 상단 여백

            // 로고
            const Icon(Icons.rice_bowl, size: 120, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              "집밥 메이트",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),

            // ID 입력
            // '_buildTextField'는 이 클래스 내부에 정의된 '헬퍼 함수(Helper Method)'입니다.
            // (코드가 중복되는 것을 방지하기 위함)
            _buildTextField(
              hint: "ID (이메일)",
              controller: _idController, // ID(이메일) 입력값을 이 컨트롤러로 관리합니다.
            ),
            const SizedBox(height: 16),

            // PW 입력
            _buildTextField(
              hint: "PW",
              isObscure: true,
              controller: _pwController, // 비밀번호 입력값을 이 컨트롤러로 관리합니다.
            ), // 'isObscure: true' 전달
            const SizedBox(height: 32),

            // 로그인 실패 시 에러 메시지 표시 영역
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16),

            // [버튼 영역]
            Row( // 버튼들을 가로(수평)로 배치
              children: [
                // Expanded: Row 안에서 남은 공간을 '차지'합니다.
                // (두 버튼이 Expanded이므로, 공간을 1:1로 '나눠' 가짐)
                Expanded(
                  // '회원가입' 버튼
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(...):
                      // '현재 화면(LoginScreen)' '위로' '새 화면(SignupScreen)'을 '쌓습니다'.
                      // (SignupScreen에서 '뒤로가기'를 누르면 LoginScreen이 나옴)
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignupScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // 흰색 버튼
                      foregroundColor: Colors.green, // 글자색 초록
                      side: const BorderSide(color: Colors.green), // 테두리
                      padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 내부 세로 여백
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0, // 그림자 없음
                    ),
                    child: const Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16), // 두 버튼 사이의 가로 간격
                Expanded(
                  // '로그인' 버튼
                  child: ElevatedButton(
                    /*  계정 서비스 로직을 위해 주석처리 했습니다.
                    onPressed: () {
                      // 화면 이동을 담당합니다.
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                            (route) => false,
                      );
                    },
                    */
                    // 로딩 중에는 버튼 비활성화, 아니면 _onLoginPressed 실행합니다.
                    onPressed: _isLoading ? null : _onLoginPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // 초록색 버튼
                      foregroundColor: Colors.white, // 글자색 흰색
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                    // 로그인 처리 중일 때는 로딩 인디케이터를 표시합니다.
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                        "로그인",
                        style: TextStyle(fontWeight: FontWeight.bold)
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

  // [헬퍼 메서드 (Helper Method)]
  // 'ID', 'PW' 입력 필드처럼 '반복되는 UI'를 생성하는 함수입니다.
  // 'hint'(안내 문구)를 받고, 'isObscure'(비밀번호 가리기) 여부를 선택적으로 받습니다.
  // TextEditingController를 파라미터로 받아 입력값을 상위에서 관리할 수 있도록 변경했습니다.
  Widget _buildTextField({
    required String hint,
    bool isObscure = false,
    required TextEditingController controller,
  }) {
    // 'isObscure' 파라미터가 'true'이면 (PW 입력 시) 텍스트를 가립니다.
    return TextField(
      controller: controller, // 각 필드의 입력값을 컨트롤러로 관리합니다.
      obscureText: isObscure,
      style: const TextStyle(color: Colors.black), // 입력되는 글자 색상
      decoration: InputDecoration( // 텍스트 필드의 '장식' (테두리, 힌트, 배경색 등)
        hintText: hint, // 'hint' 파라미터로 받은 텍스트를 힌트로 표시
        hintStyle: const TextStyle(color: Colors.grey), // 힌트 텍스트 스타일
        filled: true, // 배경색 채우기 (true)
        fillColor: Colors.white, // 배경색 (흰색)

        // enabledBorder: '일반' 상태(포커스 X)의 테두리
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300), // 연한 회색 테두리
        ),

        // focusedBorder: '포커스' 상태(키보드 활성화)의 테두리
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.green), // 포커스 시 초록 테두리
        ),

        contentPadding: const EdgeInsets.all(16), // 텍스트 필드 '내부' 여백
      ),
    );
  }
}