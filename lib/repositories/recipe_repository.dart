// RecipeRepository
// Firestore의 "recipes" 컬렉션에서 레시피 데이터를 읽어오는 역할만 담당합니다.
// 전체 레시피 목록 가져올 수 있습니다.
// 개별 레시피 가져올 수 있습니다.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeRepository {
  final FirebaseFirestore _db;

  RecipeRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // 전체 레시피 가져오기
  Future<List<Recipe>> fetchAllRecipes() async {
    final snapshot = await _db.collection('recipes').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Recipe.fromJson(data, doc.id);
    }).toList();
  }

  // ID로 단일 레시피 가져오기
  Future<Recipe?> fetchRecipeById(String id) async {
    final doc = await _db.collection('recipes').doc(id).get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    return Recipe.fromJson(data, doc.id);
  }
}
