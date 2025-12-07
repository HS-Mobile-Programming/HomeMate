import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';
import 'local_user_ingredients_cache.dart';

// 재료 변경을 알리기 위한 전역 변수
final ValueNotifier<int> alarm = ValueNotifier(0);
// 재료 정렬 모드
enum SortMode { nameAsc, nameDesc, expiryAsc, expiryDesc }

class RefrigeratorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalUserIngredientsCache _localCache = LocalUserIngredientsCache();

  // 최근 재료 리스트를 메모리에 저장하고 getEventsForDay에서 사용하기 위한 캐시
  List<Ingredient> _cachedIngredients = [];

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 사용자가 없습니다.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _ingredientCol =>
      _db.collection('users').doc(_uid).collection('ingredients');

  // 모든 재료 가져오기
  Future<List<Ingredient>> getAllIngredients() async {
    final uid = _uid;

    // 로컬 시도
    try {
      final local = _localCache.loadIngredients(uid);
      if (local.isNotEmpty) {
        _cachedIngredients = local;
        return local;
      }
    } catch (e, st) {
      debugPrint('[RefrigeratorService] getAllIngredients local error: $e\n$st');
    }

    // Firestore 가져오기 시도
    try {
      final snapshot = await _ingredientCol.get();

      final ingredients = snapshot.docs.map((doc) {
        final data = doc.data();
        return Ingredient(
          id: doc.id,
          name: data['name'] ?? '',
          quantity: (data['quantity'] ?? 1) as int,
          expiryTime: data['expiryTime'] ?? '',
        );
      }).toList();

      _cachedIngredients = ingredients;
      await _localCache.saveIngredients(uid, ingredients);
      return ingredients;
    } catch (e, st) {
      debugPrint('[RefrigeratorService] getAllIngredients Firestore error: $e\n$st');
      // 서버도 실패하면, 로컬만 반환
      return _cachedIngredients;
    }
  }

  // 로컬을 Firestore에 동기화
  Future<void> _syncIngredientsToFirestore(String uid) async {
    try {
      final col =
      _db.collection('users').doc(uid).collection('ingredients');

      // 기존 서버 데이터 전체 삭제 후
      final snapshot = await col.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      // 로컬 기준 다시 업로드
      for (final ingredient in _cachedIngredients) {
        await col.doc(ingredient.id).set({
          'name': ingredient.name,
          'quantity': ingredient.quantity,
          'expiryTime': ingredient.expiryTime,
        });
      }
    } catch (e, st) {
      debugPrint(
          '[RefrigeratorService] _syncIngredientsToFirestore error: $e\n$st');
    }
  }

  // 재료 추가하기
  Future<List<Ingredient>> addIngredient({
    required String name,
    required int quantity,
    required String expiryTime,
  }) async {
    final uid = _uid;

    // 로컬 캐시가 비어 있으면 로드
    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredients(uid);
    }

    // 새 재료 객체 생성 (로컬에서 id 생성 시도)
    final newIngredient = Ingredient(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      expiryTime: expiryTime,
    );

    // 로컬 리스트에 추가
    _cachedIngredients = List<Ingredient>.from(_cachedIngredients)
      ..add(newIngredient);

    // 로컬 저장
    await _localCache.saveIngredients(uid, _cachedIngredients);

    // UI는 로컬로 반영 그러나 Firestore 접근 가능 상태라면 백그라운드에서 동기화
    _syncIngredientsToFirestore(uid);

    // 알림 트리거
    alarm.value++;

    return _cachedIngredients;
  }

  // 재료 수정하기
  Future<List<Ingredient>> updateIngredient(
      String id, {
        required String name,
        required int quantity,
        required String expiryTime,
      }) async {
    final uid = _uid;

    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredients(uid);
    }

    _cachedIngredients = _cachedIngredients.map((ing) {
      if (ing.id == id) {
        return Ingredient(
          id: id,
          name: name,
          quantity: quantity,
          expiryTime: expiryTime,
        );
      }
      return ing;
    }).toList();

    await _localCache.saveIngredients(uid, _cachedIngredients);

    // 여기서도 동기화를 기다리지 않고 백그라운드로만 실행
    _syncIngredientsToFirestore(uid);

    alarm.value++;

    return _cachedIngredients;
  }

  // 재료 삭제하기
  Future<List<Ingredient>> deleteIngredient(String id) async {
    final uid = _uid;

    if (_cachedIngredients.isEmpty) {
      _cachedIngredients = _localCache.loadIngredients(uid);
    }

    _cachedIngredients =
        _cachedIngredients.where((ing) => ing.id != id).toList();

    await _localCache.saveIngredients(uid, _cachedIngredients);

    _syncIngredientsToFirestore(uid);

    alarm.value++;

    return _cachedIngredients;
  }

  // 유통기한 날짜 파싱
  DateTime? parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;

    try {
      // 'yyyy.MM.dd' 포맷으로 저장 기준으로 안전하게 파싱합니다.
      return DateFormat('yyyy.MM.dd').parse(dateStr);
    } catch (_) {
      // 과거 데이터 정리를 위해 한 번 더 시도합니다.
      try {
        return DateTime.parse(dateStr.replaceAll('.', '-'));
      } catch (_) {
        return null;
      }
    }
  }

  // 6. 캘린더 마커용 이벤트 가져오기 (로직)
  // (이 함수는 TableCalendar에서 동기적으로 호출하므로 Future를 적용하지 않고 그대로 둡니다.)
  List<Ingredient> getEventsForDay(DateTime day) {
    return _cachedIngredients.where((ingredient) {
      DateTime? expiryDate = parseDate(ingredient.expiryTime);
      return expiryDate != null && isSameDay(expiryDate, day);
    }).toList();
  }

  // 7. 리스트 정렬하기 (로직)
  List<Ingredient> sortList(List<Ingredient> list, SortMode mode) {
    switch (mode) {
      case SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortMode.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortMode.expiryAsc:
        list.sort((a, b) {
          final dateA = parseDate(a.expiryTime);
          final dateB = parseDate(b.expiryTime);
          if (dateA == null && dateB == null) {
            return 0;
          }
          if (dateA == null) {
            return 1;
          }
          if (dateB == null) {
            return -1;
          }
          return dateA.compareTo(dateB);
        });
        break;
      case SortMode.expiryDesc:
        list.sort((a, b) {
          final dateA = parseDate(a.expiryTime);
          final dateB = parseDate(b.expiryTime);
          if (dateA == null && dateB == null) {
            return 0;
          }
          if (dateA == null) {
            return 1;
          }
          if (dateB == null) {
            return -1;
          }
          return dateB.compareTo(dateA);
        });
        break;
    }
    return list;
  }
}