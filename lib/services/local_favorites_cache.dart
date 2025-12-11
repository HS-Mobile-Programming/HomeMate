// 즐겨찾기 로컬 캐시: Hive를 사용한 사용자별 즐겨찾기 레시피 ID 목록 저장 및 조회
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalFavoritesCache {
  // Hive 박스 이름 상수
  static const String userBoxName = 'user_data_box';

  // Hive 박스 참조 (열려있지 않으면 null)
  Box? get _localBox =>
      Hive.isBoxOpen(userBoxName) ? Hive.box(userBoxName) : null;

  // 즐겨찾기 목록을 로컬 캐시에 저장
  Future<void> saveFavoritesToLocalCache(
    String _uid,
    List<String> _recipeIds,
  ) async {
    try {
      final _box = _localBox;
      if (_box == null) return;

      final _jsonString = jsonEncode(_recipeIds);
      await _box.put('favorites_$_uid', _jsonString);
    } catch (e) {}
  }

  // 로컬 캐시에서 즐겨찾기 목록 조회
  List<String> loadFavoritesFromLocalCache(String _uid) {
    try {
      final _box = _localBox;
      if (_box == null) return [];

      final _raw = _box.get('favorites_$_uid');
      if (_raw is! String) return [];

      final _decoded = jsonDecode(_raw);
      if (_decoded is! List) return [];

      return _decoded.map((_item) => _item.toString()).toList();
    } catch (e) {
      return [];
    }
  }

  // 로컬 캐시에서 즐겨찾기 목록 삭제 (로그아웃 시 사용)
  Future<void> clearFavoritesFromLocalCache(String _uid) async {
    try {
      final _box = _localBox;
      if (_box == null) return;
      await _box.delete('favorites_$_uid');
    } catch (e) {}
  }
}