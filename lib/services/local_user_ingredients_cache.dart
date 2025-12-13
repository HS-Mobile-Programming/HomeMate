// 사용자 재료 목록의 로컬 캐시 관리: Hive 박스를 사용한 오프라인 데이터 저장소
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';

class LocalUserIngredientsCache {
  // Hive 박스 이름 상수
  static const String userBoxName = 'user_data_box';

  // Hive 박스 참조 반환 (열려 있지 않으면 null)
  Box? get _boxOrNull =>
      Hive.isBoxOpen(userBoxName) ? Hive.box(userBoxName) : null;

  // 사용자 재료 목록을 로컬 캐시에 JSON 형식으로 저장
  Future<void> saveIngredientsToLocalCache(
    String _uid,
    List<Ingredient> _ingredientsList,
  ) async {
    try {
      final _localBox = _boxOrNull;
      if (_localBox == null) {
        return;
      }

      final _mappedIngredients = _ingredientsList
          .map(
            (_ingredient) => {
              'id': _ingredient.id,
              'name': _ingredient.name,
              'quantity': _ingredient.quantity,
              'expiryTime': _ingredient.expiryTime,
            },
          )
          .toList();

      final _jsonString = jsonEncode(_mappedIngredients);
      await _localBox.put('ingredients_$_uid', _jsonString);
    }
    catch (e) {
      debugPrint('재료 목록 저장 중 오류 발생: $e');
    }
  }

  // 로컬 캐시에서 사용자 재료 목록을 조회하여 Ingredient 객체로 변환
  List<Ingredient> loadIngredientsFromLocalCache(String _uid) {
    try {
      final _localBox = _boxOrNull;
      if (_localBox == null) return [];

      final _rawData = _localBox.get('ingredients_$_uid');
      if (_rawData is! String) return [];

      final _decodedList = jsonDecode(_rawData);
      if (_decodedList is! List) return [];

      final List<Ingredient> _ingredients = [];

      for (final _item in _decodedList) {
        if (_item is Map<String, dynamic>) {
          _ingredients.add(
            Ingredient(
              id: _item['id'] as String? ?? '',
              name: _item['name'] as String? ?? '',
              quantity: (_item['quantity'] ?? 1) as int,
              expiryTime: _item['expiryTime'] as String? ?? '',
            ),
          );
        }
        else if (_item is Map) {
          final _map = Map<String, dynamic>.from(_item);
          _ingredients.add(
            Ingredient(
              id: _map['id'] as String? ?? '',
              name: _map['name'] as String? ?? '',
              quantity: (_map['quantity'] ?? 1) as int,
              expiryTime: _map['expiryTime'] as String? ?? '',
            ),
          );
        }
      }

      return _ingredients;
    }
    catch (e) {
      debugPrint('재료 목록 로드/파싱 실패: $e');
      return [];
    }
  }

  // 로컬 캐시에서 사용자 재료 목록 삭제
  Future<void> clearIngredientsFromLocalCache(String _uid) async {
    try {
      final _localBox = _boxOrNull;
      if (_localBox == null) return;
      await _localBox.delete('ingredients_$_uid');
    }
    catch (e) {
      debugPrint('로컬 데이터 삭제 실패: $e');
    }
  }
}