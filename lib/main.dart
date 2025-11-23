import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
// import 'package:firebase_core/firebase_core.dart';  // Import Firebase Package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();     // Initialize Firebase
  runApp(const HomeMateApp());
}

class HomeMateApp extends StatelessWidget {
  const HomeMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집밥 메이트',
      theme: ThemeData(
        useMaterial3: true,
        // [수정] 색상 체계를 중앙에서 관리합니다.
        // seedColor를 지정하면 어울리는 색상 팔레트가 자동 생성됩니다.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, // 메인 색상
          primary: Colors.green,   // 주요 버튼, 활성 상태 색상
          // surface: 카드나 시트의 배경색
          surface: Colors.white,
          // background: 앱 전체 배경색
          surfaceContainerLowest: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // [수정] 카드 테마 기본값 설정
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: EdgeInsets.zero,
        ),
      ),
      home: const LoadingScreen(),
    );
  }
}