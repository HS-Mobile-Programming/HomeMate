/// 앱 진입점 및 초기화 로직
/// Firebase, Hive 로컬 데이터베이스, 알림 서비스를 초기화하고 앱을 실행합니다
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/loading_screen.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

/// 앱의 진입점입니다
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _setupFcmTokenRefreshListener();
  await Hive.initFlutter();
  await Hive.openBox('recipes_box');
  await Hive.openBox('ingredient_dict_box');
  await Hive.openBox('meta_box');
  await Hive.openBox('user_data_box');

  _initializeNotificationService();

  runApp(const HomeMateApp());
}

/// 기기 변경 및 재설치에 따른 FCM 토큰을 갱신합니다
void _setupFcmTokenRefreshListener() {
  if (kIsWeb) return;

  FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || token.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  });
}

/// 사용자 로그인 상태 변경을 감지하고 알림 서비스를 초기화합니다
void _initializeNotificationService() async {
  FirebaseAuth.instance.authStateChanges().listen((User? _user) async {
    if (_user != null) {
      await NotificationService.instance.initialize();
      await NotificationService.instance.checkExpiringIngredients();
    }
  });
}

/// 앱의 루트 위젯입니다
/// 전역 테마를 설정하고 라우팅을 관리합니다
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