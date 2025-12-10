// 메인 화면 컨테이너: 로그인 후 하단 네비게이션 바를 통한 5개 탭 화면 전환 관리
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/refrigerator_screen.dart';
import 'screens/recipe_screen.dart';
import 'screens/recommendation_screen.dart';
import 'screens/mypage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 현재 선택된 탭 인덱스
  int _currentIndex = 0;

  // 탭별 화면 위젯 목록 (홈, 냉장고, 레시피, 추천, 마이페이지)
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
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
