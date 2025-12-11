// AI 기반 레시피 추천 서비스: Gemini AI를 활용한 사용자 선호 태그 기반 맞춤형 레시피 추천
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecommendationService {

  // --- 1. Gemini AI 설정 ---
  // 여기에 발급받은 Gemini API 키를 입력하세요.
  // 보안을 위해 실제 앱에서는 환경 변수나 별도의 키 관리 서비스를 사용하는 것이 좋습니다.
  // [주의] Git에 올릴 때는 이 키를 지우고 올리는 것이 안전합니다.
  static const String _apiKey = ""; // <--- 여기에 API 키를 입력하세요

  // 레시피 서비스 (전체 레시피 데이터 조회용)
  final RecipeService _recipeService = RecipeService();

  // 사용자 선호 태그를 기반으로 AI 추천 레시피 조회
  Future<List<Recipe>> getRecommendations({List<String>? selectedTags}) async {
    final List<String> _sortedTags;
    if (selectedTags != null && selectedTags.isNotEmpty) {
      _sortedTags = List<String>.from(selectedTags)..sort();
    } else {
      _sortedTags = <String>[];
    }

    final _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
    final _allRecipes = await _recipeService.getRecipes();
    final _allRecipesJsonString = jsonEncode(
      _allRecipes.map((_r) => _r.toJson()).toList(),
    );

    String _tagInfo = "";
    if (_sortedTags.isNotEmpty) {
      _tagInfo =
          """
      
      [사용자 선호 태그]
      ${_sortedTags.join(', ')}
      
      위 태그들을 고려하여 추천해줘. 태그에 맞는 레시피를 우선적으로, 랜덤하게 추천해줘""";

      final _difficultyTags = _sortedTags
          .where((_tag) => ['초급', '중급', '고급'].contains(_tag))
          .toList();
      if (_difficultyTags.isNotEmpty) {
        _tagInfo += "\n난이도: ${_difficultyTags.join(', ')}를 선호합니다.";
      }

      final _timeTags = _sortedTags
          .where((_tag) => ['15분', '30분', '60분 이상'].contains(_tag))
          .toList();
      if (_timeTags.isNotEmpty) {
        _tagInfo += "\n조리시간: ${_timeTags.join(', ')}의 레시피를 선호합니다.";
      }
    } else {
      _tagInfo = """
      
      사용자가 특별한 선호 태그를 설정하지 않았으므로, 다양한 레시피를 추천해줘.""";
    }

    final _prompt =
        """다음은 우리가 가진 전체 레시피 목록이야.
        이 목록을 보고 사용자에게 추천할 만한 레시피 최대 5개를 골라줘.
      $_tagInfo
      결과는 다른 설명 없이, 추천하는 레시피의 'id' 값만 쉼표(,)로 구분해서 알려줘.
      예를 들어, 'recipe-001,recipe-008,recipe-015' 와 같은 형식으로 응답해줘.

      [전체 레시피 목록]
      $_allRecipesJsonString""";

    final _content = [Content.text(_prompt)];

    try {
      final _response = await _model.generateContent(_content);
      final _recommendedIds = _response.text
          ?.split(',')
          .map((_id) => _id.trim())
          .where((_id) => _id.isNotEmpty)
          .toList();

      if (_recommendedIds == null || _recommendedIds.isEmpty) {
        return [];
      }

      final _recommendedRecipes = _allRecipes
          .where((_recipe) => _recommendedIds.contains(_recipe.id))
          .toList();

      _recommendedRecipes.sort(
        (_a, _b) =>
            _recommendedIds.indexOf(_a.id) - _recommendedIds.indexOf(_b.id),
      );

      return _recommendedRecipes;
    }
    catch (e) {
      debugPrint("AI 호출 오류: $e");
      return [];
    }
  }

  // RecipeService의 정렬 메서드 재사용
  List<Recipe> sortRecipes(List<Recipe> _recipes, RecipeSortMode _mode) {
    return _recipeService.sortRecipes(_recipes, _mode);
  }
}