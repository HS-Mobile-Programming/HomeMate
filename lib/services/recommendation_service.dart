// lib/services/recommendation_service.dart

import 'dart:convert'; // Recipe 객체를 JSON으로 변환하기 위해 추가
import 'package:google_generative_ai/google_generative_ai.dart'; // Gemini AI 패키지 import
import '../models/recipe.dart';
//import '../data/recipe_data.dart'; // AI에게 보낼 전체 레시피 데이터를 위해 유지
import '../services/recipe_service.dart'; // Firestore 기반 레시피 로딩으로 전환
import 'recipe_service.dart'; // 정렬 모드(enum) 재사용

class RecommendationService {

  // --- 1. Gemini AI 설정 ---
  // 여기에 발급받은 Gemini API 키를 입력하세요.
  // 보안을 위해 실제 앱에서는 환경 변수나 별도의 키 관리 서비스를 사용하는 것이 좋습니다.
  static const String _apiKey = ""; // <--- 여기에 API 키를 입력하세요

  //
  final RecipeService _recipeService = RecipeService();

  // --- 2. 추천 레시피 조회 로직 (Gemini AI 호출 코드로 변경) ---
  Future<List<Recipe>> getRecommendations() async {
    // AI 모델 초기화
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

    // Firestore에서 전체 레시피 불러옵니다.
    final allRecipes = await _recipeService.getRecipes();

    // AI에게 전달할 전체 레시피 목록을 JSON 형식의 문자열로 변환
    final allRecipesJsonString = jsonEncode(allRecipes.map((r) => r.toJson()).toList());

    // AI에게 보낼 프롬프트(명령어) 구성
    // 이 프롬프트를 어떻게 구성하느냐에 따라 AI의 추천 결과가 달라집니다.
    final prompt = """
      다음은 우리가 가진 전체 레시피 목록이야. 이 목록을 보고 사용자에게 추천할 만한 레시피 3개를 골라줘.
      - 사용자는 요리를 이제 막 시작하는 초보자야.
      - 요리 시간이 짧고, 난이도가 '쉬움'인 레시피를 선호할 거야.
      - 결과는 다른 설명 없이, 추천하는 레시피의 'id' 값만 쉼표(,)로 구분해서 알려줘. 예를 들어, 'recipe-001,recipe-008,recipe-015' 와 같은 형식으로 응답해줘.

      [전체 레시피 목록]
      $allRecipesJsonString
    """;

    // AI 모델에 프롬프트를 전달하고 응답을 기다림
    final content = [Content.text(prompt)];

    try {
      final response = await model.generateContent(content);

      // AI의 응답 텍스트에서 추천된 레시피 ID 목록을 추출
      final recommendedIds = response.text
          ?.split(',') // 쉼표로 ID들을 분리
          .map((id) => id.trim()) // 각 ID의 양쪽 공백 제거
          .where((id) => id.isNotEmpty) //
          .toList();

      if (recommendedIds == null || recommendedIds.isEmpty) {
        // AI가 추천 ID를 반환하지 않은 경우, 빈 리스트를 반환
        return [];
      }

      // 추출된 ID 목록을 기반으로 전체 레시피(allRecipes)에서 실제 Recipe 객체를 찾아 리스트로 만듦
      final recommendedRecipes = allRecipes
          .where((recipe) => recommendedIds.contains(recipe.id))
          .toList();

      // AI가 추천한 ID 순서대로 결과를 정렬
      recommendedRecipes.sort((a, b) =>
      recommendedIds.indexOf(a.id) - recommendedIds.indexOf(b.id));

      return recommendedRecipes;

    } catch (e) {
      // API 호출 중 오류 발생 시 처리
      // 오류 발생 시 사용자에게 빈 리스트를 보여주거나, 다른 대체 로직을 수행할 수 있습니다.
      throw Exception('레시피 추천을 받아오는 데 실패했습니다.');
    }
  }

  // --- 3. 추천 레시피 정렬 로직 (기존과 동일) ---
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
}
