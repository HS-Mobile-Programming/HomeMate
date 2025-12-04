import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ingredient.dart';

// 재료 변경을 알리기 위한 전역 변수
final ValueNotifier<int> alarm = ValueNotifier(0);
// 재료 정렬 모드
enum SortMode { nameAsc, nameDesc, expiryAsc, expiryDesc }

class RefrigeratorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // 1. 모든 재료 가져오기
  Future<List<Ingredient>> getAllIngredients() async {
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

    // 캐시 업데이트
    _cachedIngredients = ingredients;
    return ingredients;
  }

  // 2. 재료 추가하기
  Future<void> addIngredient({
    required String name,
    required int quantity,
    required String expiryTime,
  }) async {
    await _ingredientCol.add({
      'name': name,
      'quantity': quantity,
      'expiryTime': expiryTime,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. 재료 수정하기
  Future<void> updateIngredient(
      String id, {
        required String name,
        required int quantity,
        required String expiryTime,
      }) async {
    await _ingredientCol.doc(id).update({
      'name': name,
      'quantity': quantity,
      'expiryTime': expiryTime,
    });
  }

  // 4. 재료 삭제하기
  Future<void> deleteIngredient(String id) async {
    await _ingredientCol.doc(id).delete();
  }

  // 5. 유통기한 날짜 파싱 (로직)
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
          DateTime? dateA = parseDate(a.expiryTime);
          DateTime? dateB = parseDate(b.expiryTime);
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
          DateTime? dateA = parseDate(a.expiryTime);
          DateTime? dateB = parseDate(b.expiryTime);
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