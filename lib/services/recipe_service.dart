// lib/services/recipe_service.dart

import '../models/recipe.dart';
import '../data/recipe_data.dart'; // 가짜 데이터베이스

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {

  // 1. 레시피 검색/조회 로직
  List<Recipe> getRecipes({String? keyword}) {
    List<Recipe> recipes;
    if (keyword == null || keyword.isEmpty) {
      recipes = allRecipes; // 전체 조회
    } else {
      // 검색 조회
      recipes = allRecipes
          .where((recipe) =>
          recipe.title.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    return recipes;
  }

  // 2. 레시피 정렬 로직
  List<Recipe> sortRecipes(List<Recipe> recipes, RecipeSortMode mode) {
    switch (mode) {
      case RecipeSortMode.nameAsc:
        recipes.sort((a, b) => a.title.compareTo(b.title));
        break;
      case RecipeSortMode.nameDesc:
        recipes.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
    return recipes;
  }

  // 3. 즐겨찾기 조회 로직
  List<Recipe> getFavoriteRecipes() {
    // (나중에 여기를 Firebase 'where' 쿼리로 변경)
    return allRecipes.where((r) => r.isFavorite).toList();
  }

  // 4. 즐겨찾기 상태 변경 로직
  void toggleFavorite(Recipe recipe) {
    // (나중에 여기를 Firebase 'update' 쿼리로 변경)
    recipe.isFavorite = !recipe.isFavorite;
  }
}