// 냉장고 재료 관리 및 동기화 서비스: Firestore와 로컬 캐시 간 재료 CRUD 및 양방향 동기화, 캘린더 마커 지원
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';
import 'local_user_ingredients_cache.dart';

// 재료 변경 알림용 전역 노티파이어
final ValueNotifier<int> alarm = ValueNotifier(0);

// 재료 정렬 모드
enum SortMode { nameAsc, nameDesc, expiryAsc, expiryDesc }

class RefrigeratorService {
  // Firestore 데이터베이스 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Firebase 인증 인스턴스
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // 로컬 재료 캐시
  final LocalUserIngredientsCache _localCache = LocalUserIngredientsCache();

  // 메모리 캐시 (캘린더 마커 등 동기 접근용)
  List<Ingredient> _cachedIngredients = [];

  // 현재 로그인 사용자 uid
  String get _uid {
    final _user = _auth.currentUser;
    if (_user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }
    return _user.uid;
  }

  // Firestore 재료 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _ingredientCollection =>
      _firestore.collection('users').doc(_uid).collection('ingredients');

  // 모든 재료 조회 (로컬 캐시 우선, 실패 시 Firestore 동기화)
  Future<List<Ingredient>> getAllIngredients() async {
    final _uid = this._uid;

    try {
      final _local = _localCache.loadIngredientsFromLocalCache(_uid);
      if (_local.isNotEmpty) {
        _cachedIngredients = _local;
        return _local;
      }
    } catch (e) {
      debugPrint('[RefrigeratorService] 로컬 로드 오류: $e');
    }

    try {
      final _snapshot = await _ingredientCollection.get();
      final _ingredients = _snapshot.docs.map((_doc) {
        final _data = _doc.data();
        return Ingredient(
          id: _doc.id,
          name: _data['name'] ?? '',
          quantity: (_data['quantity'] ?? 1) as int,
          expiryTime: _data['expiryTime'] ?? '',
        );
      }).toList();

      _cachedIngredients = _ingredients;
      await _localCache.saveIngredientsToLocalCache(_uid, _ingredients);
      return _ingredients;
    } catch (e) {
      debugPrint('[RefrigeratorService] Firestore 로드 오류: $e');
      return _cachedIngredients;
    }
  }

  // 로컬 캐시 기준 Firestore 동기화
  Future<void> _syncIngredientsToFirestore(String _uid) async {
    try {
      final _col = _firestore
          .collection('users')
          .doc(_uid)
          .collection('ingredients');
      final _snapshot = await _col.get();
      for (final _doc in _snapshot.docs) {
        await _doc.reference.delete();
      }
      for (final _ingredient in _cachedIngredients) {
        await _col.doc(_ingredient.id).set({
          'name': _ingredient.name,
          'quantity': _ingredient.quantity,
          'expiryTime': _ingredient.expiryTime,
        });
      }
    } catch (e) {
      debugPrint('[RefrigeratorService] 동기화 오류: $e');
    }
  }

  // 재료 추가 (로컬 저장 후 백그라운드 동기화)
  Future<List<Ingredient>> addIngredient({
    required String name,
    required int quantity,
    required String expiryTime,
  }) async {
    final _uid = this._uid;

    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredientsFromLocalCache(_uid);
    }

    try {
      final existingIngredient = _cachedIngredients.firstWhere(
            (ing) => ing.name == name && ing.expiryTime == expiryTime,
      );
      final updatedIngredient = Ingredient(
        id: existingIngredient.id,
        name: existingIngredient.name,
        expiryTime: existingIngredient.expiryTime,
        quantity: existingIngredient.quantity + quantity,
      );
      final index = _cachedIngredients.indexOf(existingIngredient);
      _cachedIngredients[index] = updatedIngredient;
    } catch (e) {
      final _newIngredient = Ingredient(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        quantity: quantity,
        expiryTime: expiryTime,
      );
      _cachedIngredients = List<Ingredient>.from(_cachedIngredients)
        ..add(_newIngredient);
    }

    await _localCache.saveIngredientsToLocalCache(_uid, _cachedIngredients);
    _syncIngredientsToFirestore(_uid);
    alarm.value++;

    return _cachedIngredients;
  }

  // 재료 수정 (로컬 저장 후 백그라운드 동기화)
  Future<List<Ingredient>> updateIngredient(
    String _id, {
    required String name,
    required int quantity,
    required String expiryTime,
  }) async {
    final _uid = this._uid;

    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredientsFromLocalCache(_uid);
    }

    _cachedIngredients = _cachedIngredients.map((_ing) {
      if (_ing.id == _id) {
        return Ingredient(
          id: _id,
          name: name,
          quantity: quantity,
          expiryTime: expiryTime,
        );
      }
      return _ing;
    }).toList();

    await _localCache.saveIngredientsToLocalCache(_uid, _cachedIngredients);
    _syncIngredientsToFirestore(_uid);
    alarm.value++;

    return _cachedIngredients;
  }

  // 재료 삭제 (로컬 저장 후 백그라운드 동기화)
  Future<List<Ingredient>> deleteIngredient(String _id) async {
    final _uid = this._uid;

    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredientsFromLocalCache(_uid);
    }

    _cachedIngredients = _cachedIngredients
        .where((_ing) => _ing.id != _id)
        .toList();
    await _localCache.saveIngredientsToLocalCache(_uid, _cachedIngredients);
    _syncIngredientsToFirestore(_uid);
    alarm.value++;

    return _cachedIngredients;
  }

  // 유통기한 문자열 파싱 (yyyy.MM.dd 형식)
  DateTime? parseDate(String _dateStr) {
    if (_dateStr.isEmpty) return null;

    try {
      return DateFormat('yyyy.MM.dd').parse(_dateStr);
    } catch (_) {
      try {
        return DateTime.parse(_dateStr.replaceAll('.', '-'));
      } catch (_) {
        return null;
      }
    }
  }

  // 캘린더 마커용 특정 날짜의 재료 조회
  List<Ingredient> getEventsForDay(DateTime _day) {
    return _cachedIngredients.where((_ingredient) {
      final _expiryDate = parseDate(_ingredient.expiryTime);
      return _expiryDate != null && isSameDay(_expiryDate, _day);
    }).toList();
  }

  // 재료 리스트 정렬
  List<Ingredient> sortList(List<Ingredient> _list, SortMode _mode) {
    switch (_mode) {
      case SortMode.nameAsc:
        _list.sort((_a, _b) => _a.name.compareTo(_b.name));
        break;
      case SortMode.nameDesc:
        _list.sort((_a, _b) => _b.name.compareTo(_a.name));
        break;
      case SortMode.expiryAsc:
        _list.sort((_a, _b) {
          final _dateA = parseDate(_a.expiryTime);
          final _dateB = parseDate(_b.expiryTime);
          if (_dateA == null && _dateB == null) return 0;
          if (_dateA == null) return 1;
          if (_dateB == null) return -1;
          return _dateA.compareTo(_dateB);
        });
        break;
      case SortMode.expiryDesc:
        _list.sort((_a, _b) {
          final _dateA = parseDate(_a.expiryTime);
          final _dateB = parseDate(_b.expiryTime);
          if (_dateA == null && _dateB == null) return 0;
          if (_dateA == null) return 1;
          if (_dateB == null) return -1;
          return _dateB.compareTo(_dateA);
        });
        break;
    }
    return _list;
  }
}
