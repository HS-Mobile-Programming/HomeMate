import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';
import 'refrigerator_service.dart';

// 백그라운드에서 푸시 알림을 받을 때 실행되는 핸들러
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 알림 처리 로직은 여기에 추가 가능
}

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RefrigeratorService _refrigeratorService = RefrigeratorService();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid);

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 로컬 알림 초기화
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Android 알림 채널 생성
      const androidChannel = AndroidNotificationChannel(
        'expiry_channel',
        '유통기한 알림',
        description: '재료의 유통기한이 임박했을 때 알림을 받습니다.',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      // 알림 권한 요청
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }

      // FCM 토큰 가져오기 및 저장
      _fcmToken = await _messaging.getToken();
      if (_fcmToken != null) {
        await _userDoc.update({'fcmToken': _fcmToken});
      }

      // 토큰 갱신 시 자동 업데이트
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _userDoc.update({'fcmToken': newToken});
      });

      // 포그라운드에서 알림 수신 시 로컬 알림으로 표시
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showLocalNotification(
          message.notification?.title ?? '알림',
          message.notification?.body ?? '',
        );
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _isInitialized = true;
    } catch (e) {
      debugPrint('알림 초기화 오류: $e');
    }
  }

  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final doc = await _userDoc.get();
      if (doc.exists) {
        final data = doc.data();
        return {
          'isPushOn': data?['notificationEnabled'] ?? true,
          'days': data?['notificationDays'] ?? 3,
        };
      }
      return {'isPushOn': true, 'days': 3};
    } catch (e) {
      return {'isPushOn': true, 'days': 3};
    }
  }

  Future<void> saveNotificationSettings({
    required bool isPushOn,
    required int days,
  }) async {
    try {
      await _userDoc.update({
        'notificationEnabled': isPushOn,
        'notificationDays': days,
      });
    } catch (e) {
      debugPrint('알림 설정 저장 오류: $e');
    }
  }

  Future<void> checkExpiringIngredients() async {
    try {
      final settings = await getNotificationSettings();
      if (!settings['isPushOn']) return;

      final days = settings['days'] as int;
      final ingredients = await _refrigeratorService.getAllIngredients();
      final todayOnly = _getDateOnly(DateTime.now());

      // 유통기한이 임박한 재료 찾기
      final expiringIngredients = ingredients.where((ingredient) {
        final expiryDate = _refrigeratorService.parseDate(ingredient.expiryTime);
        if (expiryDate == null) return false;
        
        final expiryOnly = _getDateOnly(expiryDate);
        final remainingDays = expiryOnly.difference(todayOnly).inDays;
        return remainingDays >= 0 && remainingDays <= days;
      }).toList();

      if (expiringIngredients.isEmpty) return;

      // 이미 알림을 보낸 재료 제외
      final sentAlarms = await _getSentAlarms();
      final ingredientsToNotify = expiringIngredients.where((ingredient) {
        final alarmKey = '${ingredient.id}_${ingredient.expiryTime}';
        return !sentAlarms.contains(alarmKey);
      }).toList();

      if (ingredientsToNotify.isEmpty) return;

      // 알림 전송
      for (final ingredient in ingredientsToNotify) {
        await _sendNotification(ingredient);
        await _markAlarmAsSent(ingredient);
      }
    } catch (e) {
      debugPrint('유통기한 체크 오류: $e');
    }
  }

  // 날짜에서 시간 부분 제거 (년/월/일만)
  DateTime _getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<Set<String>> _getSentAlarms() async {
    try {
      final doc = await _userDoc.get();
      if (doc.exists) {
        final sentAlarms = doc.data()?['sentAlarms'] as List<dynamic>?;
        if (sentAlarms != null) {
          return Set<String>.from(sentAlarms);
        }
      }
      return <String>{};
    } catch (e) {
      return <String>{};
    }
  }

  Future<void> _markAlarmAsSent(Ingredient ingredient) async {
    try {
      final sentAlarms = await _getSentAlarms();
      sentAlarms.add('${ingredient.id}_${ingredient.expiryTime}');
      await _userDoc.update({'sentAlarms': sentAlarms.toList()});
    } catch (e) {
      debugPrint('알림 기록 저장 오류: $e');
    }
  }

  Future<void> _sendNotification(Ingredient ingredient) async {
    try {
      final expiryDate = _refrigeratorService.parseDate(ingredient.expiryTime);
      if (expiryDate == null) return;

      final todayOnly = _getDateOnly(DateTime.now());
      final expiryOnly = _getDateOnly(expiryDate);
      final remainingDays = expiryOnly.difference(todayOnly).inDays;

      String body;
      if (remainingDays == 0) {
        body = '${ingredient.name}의 유통기한이 오늘입니다!';
      } else if (remainingDays < 0) {
        body = '${ingredient.name}의 유통기한이 지났습니다!';
      } else {
        body = '${ingredient.name}의 유통기한이 ${remainingDays}일 남았습니다.';
      }

      await _showLocalNotification('유통기한 알림', body);
    } catch (e) {
      debugPrint('알림 전송 오류: $e');
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      '유통기한 알림',
      channelDescription: '재료의 유통기한이 임박했을 때 알림을 받습니다.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
    );
  }

  // 테스트용 알림 전송 (마이페이지에서 사용)
  Future<void> sendTestNotification() async {
    try {
      final ingredients = await _refrigeratorService.getAllIngredients();
      if (ingredients.isEmpty) return;

      await _sendNotification(ingredients.first);
    } catch (e) {
      debugPrint('테스트 알림 오류: $e');
    }
  }
}


