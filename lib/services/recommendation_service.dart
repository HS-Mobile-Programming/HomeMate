// lib/services/recommendation_service.dart

import '../models/recipe.dart';
import '../data/recipe_data.dart';
import 'recipe_service.dart'; // 정렬 모드(enum) 재사용

class RecommendationService {

  // 1. 추천 레시피 조회 로직 (AI 로직이 들어갈 곳)
  Future<List<Recipe>> getRecommendations() async {
   // await Future.delayed(const Duration(milliseconds: 500)); // 가짜 지연
    // (나중에 여기를 AI 모델 호출 코드로 변경)

    // 지금은 임시로 '쉬움' 난이도만 필터링
    return allRecipes.where((r) => r.difficulty == "쉬움").toList();
  }

  // 2. 추천 레시피 정렬 로직
  List<Recipe> sortRecipes(List<Recipe> recipes, RecipeSortMode mode) {
    // (RecipeService와 로직이 동일하지만, 나중에 추천 정렬은
    // '정확도순' 등이 추가될 수 있으므로 별도 함수로 분리)
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
}