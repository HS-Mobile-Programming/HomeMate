// [SCREEN CLASS] - StatefulWidget
// '회원가입' 화면 UI를 정의합니다.
// 'StatefulWidget':
// 이 화면은 '이용약관 동의(isAgreed)' 체크박스의 '상태(State)'를
// '스스로' 관리하고 변경해야 하므로 (true/false) StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import 'tos_screen.dart';
import '../services/account_service.dart';

class SignupScreen extends StatefulWidget {
  // const SignupScreen(...): 위젯 생성자
  const SignupScreen({super.key});

  // createState() : 이 위젯이 관리할 '상태(_SignupScreenState)' 객체를 생성합니다.
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

// 'SignupScreen'의 실제 상태와 UI를 관리하는 클래스입니다.
class _SignupScreenState extends State<SignupScreen> {
  // [상태 변수 (State Variable)]
  // 이 값이 'setState'에 의해 변경되면 화면이 다시 그려집니다.
  bool isAgreed = false; // 이용약관 동의 여부 (기본값: false)

  // 각 입력 필드의 텍스트를 제어하기 위한 컨트롤러입니다.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _pwConfirmController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // 회원가입 처리 시 로딩 상태 및 에러 메시지를 관리하기 위한 상태 변수입니다.
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    // 화면이 dispose될 때 컨트롤러도 함께 정리합니다.
    _emailController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // '회원가입 완료' 버튼을 눌렀을 때 실행되는 메서드입니다.
  // 1. 약관 동의 여부 확인
  // 2. 입력값 유효성 검사 (비어 있는지, 비밀번호 길이, 비밀번호 일치 여부)
  // 3. AccountService를 이용한 Firebase 회원가입 및 users 컬렉션에 정보 저장
  // 4. 성공 시 SnackBar 표시 후 로그인 화면으로 복귀
  Future<void> _onSignUpPressed() async {
    if (!isAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("이용약관에 동의해주세요.")),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _pwController.text.trim();
    final passwordConfirm = _pwConfirmController.text.trim();
    final nickname = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      setState(() {
        _errorText = "이메일, 비밀번호, 이름을 모두 입력해주세요.";
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorText = "비밀번호는 6자 이상이어야 합니다.";
      });
      return;
    }

    if (password != passwordConfirm) {
      setState(() {
        _errorText = "비밀번호와 비밀번호 확인이 일치하지 않습니다.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // AccountService를 통해 FirebaseAuth 회원가입 + Firestore users/{uid} 문서를 생성합니다.
      await AccountService.instance.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );

      if (!mounted) return;

      // 회원가입 성공 메시지를 출력합니다.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원가입이 완료되었습니다.")),
      );

      // 회원가입 성공 시, 로그인 화면으로 돌아갑니다.
      Navigator.pop(context);
    } catch (e) {
      // 회원가입 실패 시, AccountService에서 던진 AuthException의 message가 들어옵니다.
      setState(() {
        _errorText = e.toString();
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
      backgroundColor: const Color(0xFFF5F5F5), // 배경색

      // AppBar: 화면 상단 바
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경색 '투명'
        elevation: 0, // 그림자(음영) '없음'

        // leading: AppBar의 '왼쪽' 영역 (보통 '뒤로가기' 또는 '메뉴' 아이콘)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 검은색
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("회원가입", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true, // 제목 가운데 정렬
      ),

      // SingleChildScrollView: 키보드가 올라올 때 스크롤이 가능하도록 합니다.
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // 좌우 여백
        child: Column( // 위젯들을 세로(수직)로 배치
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.rice_bowl, size: 80, color: Colors.green), // 로고
            const SizedBox(height: 32),

            // '_buildTextField' 헬퍼 메서드(LoginScreen과 유사)를 사용하여
            // 중복되는 텍스트 필드 UI를 생성합니다.
            _buildTextField(
              "ID 입력 (이메일)",
              controller: _emailController,     //이메일 입력값 관리
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "비밀번호 입력",
              isObscure: true,
              controller: _pwController,        //비밀번호 입력값 관리
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "비밀번호 확인",
              isObscure: true,
              controller: _pwConfirmController, //비밀번호 확인 입력값 관리
            ),
            const SizedBox(height: 16),
            _buildTextField(
              "이름 (닉네임)",
              controller: _nameController,      //닉네임 입력값 관리
            ),

            const SizedBox(height: 24),

            // [이용약관 체크박스 영역]
            Row( // 위젯들을 가로(수평)로 배치
              children: [
                Checkbox(
                  value: isAgreed, // '상태 변수(isAgreed)'의 현재 값을 사용
                  // onChanged: 체크박스의 상태가 '변경될 때' 호출되는 콜백 함수
                  onChanged: (value) {
                    // 'setState()': 플러터에게 "상태가 변경되었으니 화면을 다시 그려라"라고 알립니다.
                    setState(() {
                      // 'value' (새로운 체크 상태, true 또는 false)를
                      // 'isAgreed' 상태 변수에 '업데이트'합니다.
                      // '!' (null-assertion operator): 'value'가 'null'이 아님을 보장합니다.
                      isAgreed = value ?? false;
                    });
                  },
                  activeColor: Colors.green, // 체크되었을 때 색상
                  checkColor: Colors.white, // 체크 아이콘 색상
                ),
                const Text("이용약관에 동의합니다.", style: TextStyle(color: Colors.black)),
                const Spacer(), // 왼쪽 텍스트와 오른쪽 텍스트 사이의 공간을 모두 차지 (밀어냄)

                // GestureDetector: 텍스트("약관 보기 >")에 '탭(클릭)' 이벤트를 주기 위해 사용
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

            // 회원가입 과정에서 발생한 에러 메시지를 표시하는 영역
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _errorText!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const SizedBox(height: 24),

            // [가입 완료 버튼]
            SizedBox( // 버튼의 '가로 폭'을 설정하기 위해 사용
              width: double.infinity, // 가로 폭을 '최대'로 설정
              child: ElevatedButton(
                // 로딩 중에는 버튼 비활성화, 아니면 _onSignUpPressed 실행
                onPressed: _isLoading ? null : _onSignUpPressed,
                /* 상술한 주석의 방식으로 이전 코드를 비활성화 했습니다.
                onPressed: () {
                  // [유효성 검사]
                  // 만약 'isAgreed' (상태 변수)가 'false'이면 (동의 안 했으면)
                  if (!isAgreed) {
                    // ScaffoldMessenger: 화면 하단에 '스낵바'를 표시합니다.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("이용약관에 동의해주세요.")),
                    );
                    return; // 함수를 '종료'합니다 (가입 처리 안 함).
                  }

                  // (검사 통과 시)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("회원가입이 완료되었습니다.")),
                  );
                  Navigator.pop(context);
                },
                */
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                // 회원가입 처리 중일 때는 로딩 인디케이터 표시
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white
                  ),
                )
                    : const Text(
                  "회원가입 완료",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 (Helper Method)]
  // (LoginScreen의 _buildTextField와 동일한 구조)
  // controller를 받도록 변경했습니다.
  Widget _buildTextField(
      String hint, {
        bool isObscure = false,
        required TextEditingController controller,
      }) {
    return TextField(
      controller: controller, // 각 입력 필드의 값을 컨트롤러로 관리합니다.
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