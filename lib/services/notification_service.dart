// 재료 유통기한 알림 서비스: 로컬 알림 플러그인과 Firestore 알림 설정을 통한 유통기한 푸시 알림 관리
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';
import 'refrigerator_service.dart';

class NotificationService {
  // 싱글톤 생성자
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  // Firestore 데이터베이스 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase 인증 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 재료 관리 서비스
  final RefrigeratorService _refrigeratorService = RefrigeratorService();
  // 로컬 알림 플러그인
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 초기화 Future 중복 방지용
  Future<void>? _initFuture;
  // 초기화 완료 플래그
  bool _isInitialized = false;

  // 현재 로그인 사용자 uid
  String get _uid {
    final _user = _auth.currentUser;
    if (_user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }
    return _user.uid;
  }

  // Firestore 사용자 문서 참조
  DocumentReference<Map<String, dynamic>> get _userDocument =>
      _firestore.collection('users').doc(_uid);

  // 알림 서비스 초기화 (중복 호출 방지)
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initFuture != null) return _initFuture;
    _initFuture = _initializeInternal();
    await _initFuture;
    _initFuture = null;
  }

  // 내부 초기화 로직: 플러그인 설정 및 권한 요청
  Future<void> _initializeInternal() async {
    try {
      const _androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const _iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const _initSettings = InitializationSettings(
        android: _androidSettings,
        iOS: _iosSettings,
      );
      await _localNotifications.initialize(_initSettings);

      const _androidChannel = AndroidNotificationChannel(
        'expiry_channel',
        '유통기한 알림',
        description: '재료의 유통기한이 임박했을 때 알림을 받습니다.',
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_androidChannel);

      final _androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (_androidImpl != null) {
        await _androidImpl.requestNotificationsPermission();
      }
      final _iosImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (_iosImpl != null) {
        await _iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('알림 초기화 오류: $e');
    }
  }

  // Firestore에서 사용자 알림 설정 조회
  Future<Map<String, dynamic>> getNotificationSettingsFromFirestore() async {
    try {
      final _doc = await _userDocument.get();
      if (_doc.exists) {
        final _data = _doc.data();
        return {
          'isPushOn': _data?['notificationEnabled'] ?? true,
          'days': _data?['notificationDays'] ?? 3,
        };
      }
      return {'isPushOn': true, 'days': 3};
    } catch (e) {
      return {'isPushOn': true, 'days': 3};
    }
  }

  // Firestore에 사용자 알림 설정 저장
  Future<void> saveNotificationSettingsToFirestore({
    required bool isPushOn,
    required int days,
  }) async {
    try {
      await _userDocument.update({
        'notificationEnabled': isPushOn,
        'notificationDays': days,
      });
    } catch (e) {
      debugPrint('알림 설정 저장 오류: $e');
    }
  }

  // 유통기한이 임박한 재료를 확인하여 알림 발송
  Future<void> checkExpiringIngredients() async {
    try {
      final _settings = await getNotificationSettingsFromFirestore();
      if (!_settings['isPushOn']) {
        return;
      }

      final _days = _settings['days'] as int;
      final _ingredients = await _refrigeratorService.getAllIngredients();
      final _todayOnly = _getDateOnly(DateTime.now());

      final _expiringIngredients = _ingredients.where((_ingredient) {
        final _expiryDate = _refrigeratorService.parseDate(
          _ingredient.expiryTime,
        );
        if (_expiryDate == null) {
          return false;
        }

        final _expiryOnly = _getDateOnly(_expiryDate);
        final _remainingDays = _expiryOnly.difference(_todayOnly).inDays;
        return _remainingDays <= _days;
      }).toList();

      if (_expiringIngredients.isEmpty) {
        return;
      }

      for (final _ingredient in _expiringIngredients) {
        await _sendNotification(_ingredient);
      }
    }
    catch (e) {
      debugPrint('유통기한 체크 오류: $e');
    }
  }

  // 날짜의 시간 정보를 제거하여 날짜만 반환
  DateTime _getDateOnly(DateTime _date) {
    return DateTime(_date.year, _date.month, _date.day);
  }

  // 단일 재료에 대한 유통기한 알림 발송
  Future<void> _sendNotification(Ingredient _ingredient) async {
    try {
      final _expiryDate = _refrigeratorService.parseDate(
        _ingredient.expiryTime,
      );
      if (_expiryDate == null) return;

      final _todayOnly = _getDateOnly(DateTime.now());
      final _expiryOnly = _getDateOnly(_expiryDate);
      final _remainingDays = _expiryOnly.difference(_todayOnly).inDays;

      final _body = _remainingDays == 0
          ? '${_ingredient.name}의 유통기한이 오늘입니다!'
          : _remainingDays < 0
          ? '${_ingredient.name}의 유통기한이 지났습니다!'
          : '${_ingredient.name}의 유통기한이 ${_remainingDays}일 남았습니다.';
      await _showLocalNotification('유통기한 알림', _body);
    }
    catch (e) {
      debugPrint('알림 전송 오류: $e');
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(String _title, String _body) async {
    const _androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      '유통기한 알림',
      channelDescription: '재료의 유통기한이 임박했을 때 알림을 받습니다.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const _iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const _notificationDetails = NotificationDetails(
      android: _androidDetails,
      iOS: _iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      _title,
      _body,
      _notificationDetails,
    );
  }

}