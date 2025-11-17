// [APP ENTRY POINT]
// 이 파일은 Flutter 앱이 가장 먼저 실행하는 '시작점'입니다.

import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'screens/loading_screen.dart'; // 로딩 스크린 import

// [main 함수]
// Flutter 앱의 최상위 실행 함수입니다.
void main() async {
  // WidgetsFlutterBinding.ensureInitialized():
  // 'main' 함수 내부에서 'await' (비동기 작업)을 사용하기 전에
  // Flutter 엔진이 위젯을 그릴 준비가 되었는지 확인하고 초기화하는 역할입니다. (필수)
  WidgetsFlutterBinding.ensureInitialized();

  // (주석 처리됨) await Firebase.initializeApp();
  // -> 나중에 Firebase(데이터베이스, 인증 등)를 사용한다면
  //    이 주석을 풀어서 앱 시작 시 Firebase를 초기화해야 합니다.

  // runApp(): 플러터 앱을 실행하는 함수입니다.
  // 'const HomeMateApp()' 위젯을 앱의 '루트(root)' 위젯으로 지정하여
  // 화면에 그리도록 명령합니다.
  runApp(const HomeMateApp());
}

// [StatelessWidget]
// 'HomeMateApp' 위젯: 앱 전체의 '뿌리(Root)'가 되는 위젯입니다.
// 앱의 기본 테마, 타이틀, 시작 화면(home)을 정의합니다.
class HomeMateApp extends StatelessWidget {
  // 위젯 생성자
  const HomeMateApp({super.key});

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // MaterialApp: 'Material Design' 테마를 사용하는 앱을 만드는
    // 최상위 컨테이너 위젯입니다.
    // (화면 이동(Navigator), 테마 관리 등을 제공합니다.)
    return MaterialApp(
      title: '집밥 메이트', // 앱의 제목 (예: OS 작업 관리자에 표시됨)

      // theme: 앱 전체의 '디자인 테마'를 설정합니다.
      theme: ThemeData(
        // useMaterial3: Material Design 3 (최신 버전) 스타일을 사용할지 여부 (true)
        useMaterial3: true,
        // colorScheme: 앱의 '기본 색상 조합'을 정의합니다.
        // 'fromSeed(seedColor: Colors.green)':
        // 'Colors.green' (초록색)을 '기준색(seed)'으로 삼아,
        // 'primary'(주요색), 'secondary'(보조색), 'background'(배경색) 등
        // 다양한 색상들을 '자동으로' 생성하여 적용합니다.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),

        // 'Scaffold' 위젯(화면의 기본 구조)의 기본 배경색을
        // '0xFFF5F5F5' (연한 회색)으로 '덮어씌웁니다(override)'.
        // (seedColor로 생성된 자동 배경색을 쓰지 않고, 이 색을 강제로 사용)
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),

      // home: 앱이 실행되었을 때 '가장 처음' 보여줄 화면(위젯)을 지정합니다.
      // -> 앱이 시작되면 'LoadingScreen'을 먼저 보여줍니다.
      home: const LoadingScreen(),
    );
  }
}