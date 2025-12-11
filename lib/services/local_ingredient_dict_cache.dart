// 재료 사전 로컬 캐시: Hive를 사용한 재료 사전 목록 저장 및 동기화 상태 관리
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient_dictionary.dart';

class LocalIngredientDictCache {
  // Hive 박스 이름 상수
  static const String DICT_BOX_NAME = 'ingredient_dict_box';
  static const String META_BOX_NAME = 'meta_box';

  // 재료 사전 데이터 박스 참조
  Box? get _dictBox =>
      Hive.isBoxOpen(DICT_BOX_NAME) ? Hive.box(DICT_BOX_NAME) : null;

  // 동기화 메타데이터 박스 참조
  Box? get _metaBox =>
      Hive.isBoxOpen(META_BOX_NAME) ? Hive.box(META_BOX_NAME) : null;

  // 재료 사전 목록을 로컬 캐시에 저장 및 동기화 시각 기록
  Future<void> saveAll(List<IngredientDictionary> _items) async {
    await saveAllToCache(_items);
  }

  // 재료 사전 목록을 로컬 캐시에 저장
  Future<void> saveAllToCache(List<IngredientDictionary> _items) async {
    try {
      final _box = _dictBox;
      final _meta = _metaBox;
      if (_box == null || _meta == null) return;

      final _list = _items.map((_item) => _item.toMap()).toList();
      final _jsonString = jsonEncode(_list);

      await _box.put('ingredient_dict_json', _jsonString);
      await _meta.put(
        'ingredient_dict_last_sync',
        DateTime.now().toIso8601String(),
      );
    } catch (_) {}
  }

  // 로컬 캐시에서 재료 사전 목록 조회
  List<IngredientDictionary> getAll() => loadAllFromCache();

  // 로컬 캐시에서 재료 사전 목록 조회
  List<IngredientDictionary> loadAllFromCache() {
    try {
      final _box = _dictBox;
      if (_box == null) return [];

      final _raw = _box.get('ingredient_dict_json');
      if (_raw is! String) return [];

      final _decoded = jsonDecode(_raw);
      if (_decoded is! List) return [];

      final List<IngredientDictionary> _result = [];
      for (final _item in _decoded) {
        if (_item is Map<String, dynamic>) {
          _result.add(
            IngredientDictionary.fromJson(_item, _item['id'] as String? ?? ''),
          );
        } else if (_item is Map) {
          final _map = Map<String, dynamic>.from(_item);
          _result.add(
            IngredientDictionary.fromJson(_map, _map['id'] as String? ?? ''),
          );
        }
      }
      return _result;
    } catch (_) {
      return [];
    }
  }

  // 오늘 이미 동기화했는지 여부 확인
  bool isSyncedToday() => isSyncedTodayInCache();

  // 오늘 이미 동기화했는지 여부 확인
  bool isSyncedTodayInCache() {
    try {
      final _meta = _metaBox;
      if (_meta == null) return false;

      final _value = _meta.get('ingredient_dict_last_sync');
      if (_value is! String) return false;

      final _lastSync = DateTime.parse(_value);
      final _now = DateTime.now();

      return _lastSync.year == _now.year &&
          _lastSync.month == _now.month &&
          _lastSync.day == _now.day;
    } catch (_) {
      return false;
    }
  }
}