// [SCREEN CLASS] - StatefulWidget
// 로그인 '후'의 메인 화면입니다.
// 하단 네비게이션 바(BottomNavigationBar)를 가지고 있으며,
// 5개의 서로 다른 탭(화면)을 전환하는 '컨테이너' 역할을 합니다.
//
// 'StatefulWidget':
// 사용자가 '어떤 탭을 선택했는지(currentIndex)'를 '상태(State)'로
// 기억하고 변경해야 하므로 StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
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
        currentIndex: _currentIndex,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        type: BottomNavigationBarType.fixed,
        
        // 배경색 : 흰색
        backgroundColor: Colors.white,

        // 선택된 아이템: 검은색 -> 테마의 메인 색상 (primary)
        selectedItemColor: colorScheme.primary,

        // 선택되지 않은 아이템: 회색 유지 (또는 onSurfaceVariant 사용 가능)
        unselectedItemColor: Colors.grey,

        // [옵션] 선택된 라벨의 글자 굵기 등 스타일 지정 가능
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: '냉장고'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '레시피'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: '추천'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}