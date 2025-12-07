import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LocalFavoritesCache {
  static const String userBoxName = 'user_data_box';

  Box? get _boxOrNull =>
      Hive.isBoxOpen(userBoxName) ? Hive.box(userBoxName) : null;

  Future<void> saveFavorites(String uid, List<String> recipeIds) async {
    try {
      final box = _boxOrNull;
      if (box == null) {
        return;
      }

      final jsonString = jsonEncode(recipeIds);
      await box.put('favorites_$uid', jsonString);
    } catch (e, st) {
    }
  }

  List<String> loadFavorites(String uid) {
    try {
      final box = _boxOrNull;
      if (box == null) return [];

      final raw = box.get('favorites_$uid');
      if (raw is! String) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded.map((e) => e.toString()).toList();
    } catch (e, st) {
      return [];
    }
  }

  Future<void> clearFavorites(String uid) async {
    try {
      final box = _boxOrNull;
      if (box == null) return;
      await box.delete('favorites_$uid');
    } catch (e, st) {
    }
  }
}