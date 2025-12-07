import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ingredient.dart';

class LocalUserIngredientsCache {
  static const String userBoxName = 'user_data_box';

  Box? get _boxOrNull =>
      Hive.isBoxOpen(userBoxName) ? Hive.box(userBoxName) : null;

  Future<void> saveIngredients(String uid, List<Ingredient> items) async {
    try {
      final box = _boxOrNull;
      if (box == null) {
        return;
      }

      final list = items
          .map((i) => {
        'id': i.id,
        'name': i.name,
        'quantity': i.quantity,
        'expiryTime': i.expiryTime,
      })
          .toList();

      final jsonString = jsonEncode(list);
      await box.put('ingredients_$uid', jsonString);
    } catch (e, st) {
    }
  }

  List<Ingredient> loadIngredients(String uid) {
    try {
      final box = _boxOrNull;
      if (box == null) return [];

      final raw = box.get('ingredients_$uid');
      if (raw is! String) return [];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      final List<Ingredient> result = [];

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          result.add(Ingredient(
            id: item['id'] as String? ?? '',
            name: item['name'] as String? ?? '',
            quantity: (item['quantity'] ?? 1) as int,
            expiryTime: item['expiryTime'] as String? ?? '',
          ));
        } else if (item is Map) {
          final map = Map<String, dynamic>.from(item as Map);
          result.add(Ingredient(
            id: map['id'] as String? ?? '',
            name: map['name'] as String? ?? '',
            quantity: (map['quantity'] ?? 1) as int,
            expiryTime: map['expiryTime'] as String? ?? '',
          ));
        }
      }

      return result;
    } catch (e, st) {
      return [];
    }
  }

  Future<void> clearIngredients(String uid) async {
    try {
      final box = _boxOrNull;
      if (box == null) return;
      await box.delete('ingredients_$uid');
    } catch (e, st) {
    }
  }
}