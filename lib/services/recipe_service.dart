// lib/services/recipe_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';
// 레시피 더미 데이터를 사용하지 않을 예정입니다.
//import '../data/recipe_data.dart';

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Firestore에서 불러온 레시피들을 앱 실행 중 캐시해두는 리스트
  List<Recipe>? _cachedRecipes;

  // 내부용 : Firestore에서 전체 레시피 불러오고, 한 번만 캐싱합니다.
  Future<List<Recipe>> _loadAllRecipes() async {
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    final snapshot = await _db.collection('recipes').get();
    _cachedRecipes = snapshot.docs
        .map((doc) => Recipe.fromJson(doc.data(), doc.id))
        .toList();

    return _cachedRecipes!;
  }

  // 1. 레시피 검색/조회 로직
  Future<List<Recipe>> getRecipes({String? keyword}) async {
    /*
    // await Future.delayed(const Duration(milliseconds: 500)); // 가짜 지연

    List<Recipe> recipes;
    if (keyword == null || keyword.isEmpty) {
      recipes = allRecipes; // 전체 조회
    } else {
      // 오류수정: 이름만이 아니라 정상적으로 이름 또는 재료 검색이 되도록 수정
      final keywordLower = keyword.toLowerCase();
      recipes = allRecipes
          .where((recipe) =>
              recipe.name.toLowerCase().contains(keywordLower) ||
              // ingredients 리스트의 각 요소(재료)를 확인하여 재료명에 키워드가 포함되는지 검사
              recipe.ingredients.any((ingredient) =>
                  ingredient.ingredientName.toLowerCase().contains(keywordLower)))
          .toList();
    }
    return recipes;
    */
    // Firestore에서 전체 레시피 가져오기
    final recipes = await _loadAllRecipes();

    // 검색어 없으면 전체 반환
    if (keyword == null || keyword.isEmpty) {
      // 원본 캐시 보호를 위해 복사본 반환
      return List<Recipe>.from(recipes);
    }

    final keywordLower = keyword.toLowerCase();

    // 이름 또는 재료명(ingredientName)에 키워드가 포함되는지 검사
    return recipes.where((recipe) {
      final nameMatch = recipe.name.toLowerCase().contains(keywordLower);

      final ingredientMatch = recipe.ingredients.any((ingredient) =>
          ingredient.ingredientName.toLowerCase().contains(keywordLower));

      return nameMatch || ingredientMatch;
    }).toList();
  }


  // 2. 레시피 정렬 로직
  List<Recipe> sortRecipes(List<Recipe> recipes, RecipeSortMode mode) {
    switch (mode) {
      case RecipeSortMode.nameAsc:
        recipes.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RecipeSortMode.nameDesc:
        recipes.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    return recipes;
  }

  // 3. 즐겨찾기 조회 로직
  Future<List<Recipe>> getFavoriteRecipes() async {
    /*
    // await Future.delayed(const Duration(milliseconds: 500)); // 가짜 지연
    // (나중에 여기를 Firebase 'where' 쿼리로 변경)
    return allRecipes.where((r) => r.isFavorite).toList();
    */

    final recipes = await _loadAllRecipes();
    return recipes.where((r) => r.isFavorite).toList();
  }

  // 4. 즐겨찾기 상태 변경 로직
  Future<void> toggleFavorite(Recipe recipe) async {
    // await Future.delayed(const Duration(milliseconds: 300)); // 가짜 지연
    // (나중에 여기를 Firebase 'update' 쿼리로 변경)

    // 지금은 로컬 객체만 수정합니다.
    // 나중에 계정/DB 연동 시 여기에서 Firestore 업데이트로 바꿀 예정입니다.
    recipe.isFavorite = !recipe.isFavorite;
  }
}
