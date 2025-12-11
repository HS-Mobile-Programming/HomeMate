// 앱 진입점 및 초기화: Firebase, Hive 로컬 데이터베이스, 알림 서비스 초기화 및 앱 실행
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/loading_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

// 앱 시작점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  await Hive.openBox('recipes_box');
  await Hive.openBox('ingredient_dict_box');
  await Hive.openBox('meta_box');
  await Hive.openBox('user_data_box');

  _initializeNotificationService();

  runApp(const HomeMateApp());
}

// 사용자 로그인 상태 변경 감지 및 알림 서비스 초기화
void _initializeNotificationService() async {
  FirebaseAuth.instance.authStateChanges().listen((User? _user) async {
    if (_user != null) {
      await NotificationService.instance.initialize();
      await NotificationService.instance.checkExpiringIngredients();
    }
  });
}

// 앱 루트 위젯: 전역 테마 설정 및 라우팅 관리
class HomeMateApp extends StatelessWidget {
  const HomeMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집밥 메이트',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          primary: const Color(0xFF4CAF50),
          surface: Colors.white,
          surfaceContainerLowest: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),

      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: const LoadingScreen(),
    );
  }
}