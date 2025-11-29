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

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RefrigeratorScreen(),
    const RecipeScreen(),
    const RecommendationScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.kitchen, color: Colors.green),
            const SizedBox(width: 8),
            const Text(
              "집밥 메이트",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: Colors.grey,
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