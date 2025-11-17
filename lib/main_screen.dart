// [SCREEN CLASS] - StatefulWidget
// 로그인 '후'의 메인 화면입니다.
// 하단 네비게이션 바(BottomNavigationBar)를 가지고 있으며,
// 5개의 서로 다른 탭(화면)을 전환하는 '컨테이너' 역할을 합니다.
//
// 'StatefulWidget':
// 사용자가 '어떤 탭을 선택했는지(currentIndex)'를 '상태(State)'로
// 기억하고 변경해야 하므로 StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
// 5개 탭에 해당하는 화면(Screen) 위젯들을 import 합니다.
import 'screens/home_screen.dart';
import 'screens/refrigerator_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/mypage_screen.dart';

class MainScreen extends StatefulWidget {
  // const MainScreen(...): 위젯 생성자
  const MainScreen({super.key});

  // createState() : 이 위젯이 관리할 '상태(_MainScreenState)' 객체를 생성합니다.
  @override
  State<MainScreen> createState() => _MainScreenState();
}

// [_MainScreenState]
// 'MainScreen'의 실제 상태와 UI를 관리하는 클래스입니다.
class _MainScreenState extends State<MainScreen> {
  // [상태 변수 (State Variable)]
  // 현재 선택된 탭의 인덱스(순번)입니다. (0: 홈, 1: 냉장고, ...)
  int _currentIndex = 0; // 기본값: 0 (홈 화면)

  // [화면 리스트 (List<Widget>)]
  // 5개의 탭 버튼을 눌렀을 때 'body' 영역에 보여줄 화면 위젯들의 리스트입니다.
  // 이 리스트의 '순서'는 BottomNavigationBarItem의 '순서'와 '일치'해야 합니다.
  final List<Widget> _screens = [
    const HomeScreen(), // index 0
    const RefrigeratorScreen(), // index 1
    const RecipeScreen(), // index 2
    const RecommendationScreen(), // index 3
    const MyPageScreen(), // index 4
  ];

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // Scaffold: 화면의 기본 구조 (AppBar, body, BottomNavigationBar)
    return Scaffold(
      // AppBar: 화면 상단 바
      appBar: AppBar(
        // title: 'Row'를 사용하여 아이콘과 텍스트를 가로로 배치
        title: Row(
          children: [
            Icon(Icons.kitchen, color: Colors.green), // 앱 아이콘
            const SizedBox(width: 8),
            const Text(
              "집밥 메이트",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white, // AppBar 배경색 (흰색)
        elevation: 0, // 그림자 없음
      ),

      // body: 화면의 본문 영역
      // '_screens[_currentIndex]':
      // '_screens' 리스트에서 '현재 선택된 인덱스(_currentIndex)'에
      // 해당하는 화면(위젯)을 '꺼내서' 이 자리에 표시합니다.
      // (예: _currentIndex가 0이면 HomeScreen, 2이면 RecipeScreen)
      body: _screens[_currentIndex],

      // bottomNavigationBar: 화면 하단 네비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: '현재 선택된 탭'이 몇 번째인지를 BottomNavigationBar 위젯에게 알려줍니다.
        // 이 값을 '상태 변수(_currentIndex)'와 연결해야,
        // 탭을 눌렀을 때 해당 탭 아이콘에 '활성화' 표시가 됩니다.
        currentIndex: _currentIndex,

        // onTap: 하단 탭(아이템)이 '탭(클릭)'되었을 때 호출되는 콜백 함수
        // 'index' 파라미터로 '몇 번째 탭이 눌렸는지' (0~4) 알려줍니다.
        onTap: (index) {
          // 'setState()': 플러터에게 "상태가 변경되었으니 화면을 다시 그려라"라고 알립니다.
          setState(() {
            // '눌린 탭의 인덱스(index)'를
            // '현재 인덱스 상태 변수(_currentIndex)'에 '업데이트'합니다.
            _currentIndex = index;
          });
          // -> setState가 호출되면, 'build' 메서드가 다시 실행됩니다.
          // -> 'body: _screens[_currentIndex]' 부분이
          //    새로운 '_currentIndex' 값에 해당하는 화면으로 '교체'됩니다.
        },

        // type: BottomNavigationBarType.fixed:
        // 탭이 4개 이상일 때, 탭이 '고정'되어 보이도록 설정합니다.
        // (기본값인 'shifting'은 탭을 누를 때마다 아이콘이 움직이는 애니메이션)
        type: BottomNavigationBarType.fixed,

        // selectedItemColor: '선택된' 탭의 아이콘/텍스트 색상 (검은색)
        selectedItemColor: Colors.black,
        // unselectedItemColor: '선택되지 않은' 탭의 아이콘/텍스트 색상 (회색)
        unselectedItemColor: Colors.grey,

        // items: 하단 바에 표시할 '탭 버튼'들의 리스트 (필수!)
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'), // index 0
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'), // index 1
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '레시피'), // index 2
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '추천'), // index 3
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'), // index 4
        ],
      ),
    );
  }
}