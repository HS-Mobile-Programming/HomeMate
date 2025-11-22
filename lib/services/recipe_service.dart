// lib/services/recipe_service.dart

import '../models/recipe.dart';
import '../data/recipe_data.dart';

// 레시피 정렬 모드
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeService {

  // 1. 레시피 검색/조회 로직
  Future<List<Recipe>> getRecipes({String? keyword}) async {
    // await Future.delayed(const Duration(milliseconds: 500)); // 가짜 지연

    List<Recipe> recipes;
    if (keyword == null || keyword.isEmpty) {
      recipes = allRecipes; // 전체 조회
    } else {
      // 검색 조회
      recipes = allRecipes
          .where((recipe) =>
          recipe.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    return recipes;
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
    // await Future.delayed(const Duration(milliseconds: 500)); // 가짜 지연
    // (나중에 여기를 Firebase 'where' 쿼리로 변경)
    return allRecipes.where((r) => r.isFavorite).toList();
  }

  // 4. 즐겨찾기 상태 변경 로직
  Future<void> toggleFavorite(Recipe recipe) async {
    // await Future.delayed(const Duration(milliseconds: 300)); // 가짜 지연
    // (나중에 여기를 Firebase 'update' 쿼리로 변경)
    recipe.isFavorite = !recipe.isFavorite;
  }
}