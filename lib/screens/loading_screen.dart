// [SCREEN CLASS] - StatelessWidget
// 앱 실행 시 가장 먼저 표시되는 '로딩' 또는 '스플래시' 화면입니다.
// (Stateless: 이 화면 자체는 애니메이션이나 상태 변경이 없습니다.)

import 'package:flutter/material.dart';
import 'login_screen.dart';

class LoadingScreen extends StatelessWidget {
  // const LoadingScreen(...): 위젯 생성자
  const LoadingScreen({super.key});

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // GestureDetector: 자식 위젯(Scaffold)에서 발생하는 '제스처' (터치, 드래그 등)를
    // 감지할 수 있게 해주는 위젯입니다.
    return GestureDetector(
      // onTap: 화면의 '어느 곳이든' 탭(터치)하면 실행됩니다.
      onTap: () {
        // Navigator.pushReplacement(...):
        // 화면 이동(Navigator)을 담당합니다.
        // 'pushReplacement' (교체):
        //   '현재 화면(LoadingScreen)'을 스택(stack)에서 '제거'하고,
        //   '새 화면(LoginScreen)'을 그 자리에 '대체'합니다.
        //   -> 이렇게 하면, LoginScreen에서 '뒤로가기' 버튼을 눌렀을 때
        //      LoadingScreen으로 다시 돌아오는 것을 '방지'할 수 있습니다.
        Navigator.pushReplacement(
          context,
          // MaterialPageRoute: 화면을 이동할 때 사용할 애니메이션 및 라우팅 설정
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },

      // child: GestureDetector가 감지할 영역 (화면 전체)
      child: const Scaffold(
        // 앱의 공통 배경색 (main.dart에서 설정한 색과 동일)
        backgroundColor: Color(0xFFF5F5F5),

        // body: 화면의 본문 영역
        body: Center( // 자식 위젯(Column)을 화면 정중앙에 배치
          child: Column( // 자식 위젯들을 세로(수직)로 배치
            // mainAxisAlignment: Column의 '세로' 정렬 방식
            // 'center': 세로 방향으로 정중앙에 배치
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rice_bowl, size: 100, color: Colors.green), // 로고 아이콘
              SizedBox(height: 20), // 아이콘과 텍스트 사이의 수직 간격
              Text(
                "집밥 메이트",
                style: TextStyle(
                  color: Colors.black, // 글자 검은색
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}