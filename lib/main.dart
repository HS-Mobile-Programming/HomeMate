import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
// import 'main_screen.dart'; // 기존 시작점 (이제 로그인 후 이동하므로 여기선 필요 X)
import 'screens/loading_screen.dart'; // 로딩 스크린 import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        // ... 기존 테마 설정 유지 ...
      ),
      // home: const MainScreen(),  <-- 기존 코드
      home: const LoadingScreen(), // <-- 여기를 LoadingScreen으로 변경!
    );
  }
}