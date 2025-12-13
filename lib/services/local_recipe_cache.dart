// 레시피 로컬 캐시: Hive를 사용한 레시피 목록 저장 및 동기화 상태 관리
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

class LocalRecipeCache {
  // Hive 박스 이름 상수
  static const String recipesBoxName = 'recipes_box';
  static const String metaBoxName = 'meta_box';

  // 레시피 데이터 박스 참조
  Box? get _recipesBox =>
      Hive.isBoxOpen(recipesBoxName) ? Hive.box(recipesBoxName) : null;

  // 동기화 메타데이터 박스 참조
  Box? get _metaBox =>
      Hive.isBoxOpen(metaBoxName) ? Hive.box(metaBoxName) : null;

  // 레시피 목록을 로컬 캐시에 저장 및 동기화 시각 기록
  Future<void> saveRecipes(List<Recipe> _recipes) async {
    try {
      final _box = _recipesBox;
      final _meta = _metaBox;
      if (_box == null || _meta == null) return;

      final _list = _recipes.map((_recipe) => _recipe.toJson()).toList();
      final _jsonString = jsonEncode(_list);

      await _box.put('recipes_json', _jsonString);
      await _meta.put('recipes_last_sync', DateTime.now().toIso8601String());
    }
    catch (_) {}
  }

  // 로컬 캐시에서 레시피 목록 조회
  List<Recipe> getRecipes() {
    try {
      final _box = _recipesBox;
      if (_box == null) return [];

      final _raw = _box.get('recipes_json');
      if (_raw is! String) {
        return [];
      }

      final _decoded = jsonDecode(_raw);
      if (_decoded is! List) {
        return [];
      }

      final List<Recipe> _result = [];
      for (final _item in _decoded) {
        if (_item is Map<String, dynamic>) {
          final _id = _item['id'] as String? ?? '';
          _result.add(Recipe.fromJson(_item, _id));
        }
        else if (_item is Map) {
          final _map = Map<String, dynamic>.from(_item);
          final _id = _map['id'] as String? ?? '';
          _result.add(Recipe.fromJson(_map, _id));
        }
      }
      return _result;
    }
    catch (_) {
      return [];
    }
  }

  // 오늘 이미 동기화했는지 여부 확인
  bool isSyncedToday() {
    try {
      final _meta = _metaBox;
      if (_meta == null) return false;

      final _value = _meta.get('recipes_last_sync');
      if (_value is! String) return false;

      final _lastSync = DateTime.parse(_value);
      final _now = DateTime.now();

      return _lastSync.year == _now.year &&
          _lastSync.month == _now.month &&
          _lastSync.day == _now.day;
    }
    catch (_) {
      return false;
    }
  }
}