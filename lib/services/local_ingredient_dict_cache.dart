import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient_dictionary.dart';

class LocalIngredientDictCache {
  static const String dictBoxName = 'ingredient_dict_box';
  static const String metaBoxName = 'meta_box';

  Box? get _dictBoxOrNull =>
      Hive.isBoxOpen(dictBoxName) ? Hive.box(dictBoxName) : null;

  Box? get _metaBoxOrNull =>
      Hive.isBoxOpen(metaBoxName) ? Hive.box(metaBoxName) : null;

  Future<void> saveAll(List<IngredientDictionary> items) async {
    try {
      final box = _dictBoxOrNull;
      final meta = _metaBoxOrNull;
      if (box == null || meta == null) {
        return;
      }

      final list = items.map((e) => e.toMap()).toList();
      final jsonString = jsonEncode(list);

      await box.put('ingredient_dict_json', jsonString);
      await meta.put(
        'ingredient_dict_last_sync',
        DateTime.now().toIso8601String(),
      );
    } catch (e, st) {
    }
  }

  List<IngredientDictionary> getAll() {
    try {
      final box = _dictBoxOrNull;
      if (box == null) return [];

      final raw = box.get('ingredient_dict_json');
      if (raw is! String) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final List<IngredientDictionary> result = [];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          result.add(
              IngredientDictionary.fromJson(item, item['id'] as String? ?? ''));
        } else if (item is Map) {
          final map = Map<String, dynamic>.from(item as Map);
          result.add(
              IngredientDictionary.fromJson(map, map['id'] as String? ?? ''));
        }
      }

      return result;
    } catch (e, st) {
      return [];
    }
  }

  bool isSyncedToday() {
    try {
      final meta = _metaBoxOrNull;
      if (meta == null) return false;

      final value = meta.get('ingredient_dict_last_sync');
      if (value is! String) return false;

      final last = DateTime.parse(value);
      final now = DateTime.now();

      return last.year == now.year &&
          last.month == now.month &&
          last.day == now.day;
    } catch (e, st) {
      return false;
    }
  }
}