import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();                   // Hive 초기화
  await Hive.openBox('recipes_box');          // 로컬 레시피 목록
  await Hive.openBox('ingredient_dict_box');  // 로컬 재료 사전
  await Hive.openBox('meta_box');             // 로컬 메타데이터
  await Hive.openBox('user_data_box');        // 로컬 사용자 냉장고/즐겨찾기

  // 알림 서비스 초기화
  _initializeNotificationService();
  
  runApp(const HomeMateApp());
}

// 알림 서비스 초기화
void _initializeNotificationService() async {
  // 이미 로그인된 경우 바로 초기화 (앱 시작 시 재료 체크는 initialize 내부에서 한 번만 실행)
  if (FirebaseAuth.instance.currentUser != null) {
    await NotificationService.instance.initialize();
    await NotificationService.instance.checkExpiringIngredients();
  }

  // 로그인 상태 변경 감지
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      await NotificationService.instance.initialize();
      await NotificationService.instance.checkExpiringIngredients();
    }
  });
}

class HomeMateApp extends StatelessWidget {
  const HomeMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '집밥 메이트',
      theme: ThemeData(
        useMaterial3: true,
        // 색상 체계를 중앙에서 관리합니다.
        // seedColor를 지정하면 어울리는 색상 팔레트가 자동 생성됩니다.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50), // 메인 색상
          primary: const Color(0xFF4CAF50),   // 주요 버튼, 활성 상태 색상
          // surface: 카드나 시트의 배경색
          surface: Colors.white,
          // background: 앱 전체 배경색
          surfaceContainerLowest: const Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),

        // 카드 테마 기본값 설정
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: child,
        );
      },

      home: const LoadingScreen(),
    );
  }
}