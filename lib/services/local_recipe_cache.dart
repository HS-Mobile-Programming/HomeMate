import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

class LocalRecipeCache {
  static const String recipesBoxName = 'recipes_box';
  static const String metaBoxName = 'meta_box';

  Box? get _recipesBoxOrNull =>
      Hive.isBoxOpen(recipesBoxName) ? Hive.box(recipesBoxName) : null;

  Box? get _metaBoxOrNull =>
      Hive.isBoxOpen(metaBoxName) ? Hive.box(metaBoxName) : null;

  Future<void> saveRecipes(List<Recipe> recipes) async {
    try {
      final box = _recipesBoxOrNull;
      final meta = _metaBoxOrNull;
      if (box == null || meta == null) {
        return;
      }

      final list = recipes.map((r) => r.toJson()).toList();
      final jsonString = jsonEncode(list);

      await box.put('recipes_json', jsonString);
      await meta.put(
        'recipes_last_sync',
        DateTime.now().toIso8601String(),
      );
    } catch (e, st) {
    }
  }

  List<Recipe> getRecipes() {
    try {
      final box = _recipesBoxOrNull;
      if (box == null) return [];

      final raw = box.get('recipes_json');
      if (raw is! String) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final List<Recipe> result = [];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final id = item['id'] as String? ?? '';
          result.add(Recipe.fromJson(item, id));
        } else if (item is Map) {
          final map = Map<String, dynamic>.from(item as Map);
          final id = map['id'] as String? ?? '';
          result.add(Recipe.fromJson(map, id));
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

      final value = meta.get('recipes_last_sync');
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