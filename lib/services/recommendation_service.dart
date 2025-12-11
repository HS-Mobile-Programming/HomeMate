// AI 기반 레시피 추천 서비스: Gemini AI를 활용한 사용자 선호 태그 기반 맞춤형 레시피 추천
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/refrigerator_service.dart';
import '../models/recipe_sort_mode.dart';

class RecommendationService {
  // Gemini API 키 (asset 파일에서 로드)
  static String? _apiKey;
  static const String _apiKeyAssetPath = 'assets/config/api_key.txt';

  // 레시피 서비스 (전체 레시피 데이터 조회용)
  final RecipeService _recipeService = RecipeService();
  // 냉장고 재료 서비스 (현재 보유 재료 조회용)
  final RefrigeratorService _refrigeratorService = RefrigeratorService();

  // API 키 로드 (최초 1회만 로드)
  static Future<String> _loadApiKey() async {
    if (_apiKey != null) {
      return _apiKey!;
    }

    try {
      final _loadedKey = await rootBundle.loadString(_apiKeyAssetPath);
      _apiKey = _loadedKey.trim();
      if (_apiKey!.isEmpty) {
        debugPrint('[RecommendationService] API 키가 비어있습니다. assets/config/api_key.txt 파일을 확인해주세요.');
      }
      return _apiKey!;
    } catch (e) {
      debugPrint('[RecommendationService] API 키 로드 오류: $e');
      debugPrint('[RecommendationService] assets/config/api_key.txt 파일이 존재하는지 확인해주세요.');
      _apiKey = '';
      return '';
    }
  }

  // 사용자 선호 태그를 기반으로 AI 추천 레시피 조회
  Future<List<Recipe>> getRecommendations({List<String>? selectedTags}) async {
    final List<String> _sortedTags;
    if (selectedTags != null && selectedTags.isNotEmpty) {
      _sortedTags = List<String>.from(selectedTags)..sort();
    } else {
      _sortedTags = <String>[];
    }

    // API 키 로드
    final _apiKey = await _loadApiKey();
    if (_apiKey.isEmpty) {
      debugPrint('[RecommendationService] API 키가 없어 추천을 수행할 수 없습니다.');
      return [];
    }

    final _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
    final _allRecipes = await _recipeService.getRecipes();
    final _allRecipesJsonString = jsonEncode(
      _allRecipes.map((_r) => _r.toJson()).toList(),
    );

    // 현재 냉장고에 있는 재료 조회
    List<String> _refrigeratorIngredients = [];
    try {
      final _ingredients = await _refrigeratorService.getAllIngredients();
      _refrigeratorIngredients = _ingredients.map((_ing) => _ing.name).toList();
    } catch (e) {
      debugPrint('[RecommendationService] 냉장고 재료 조회 오류: $e');
    }

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

    // 냉장고 재료 정보 추가
    String _refrigeratorInfo = "";
    if (_refrigeratorIngredients.isNotEmpty) {
      _refrigeratorInfo = """
      
      [현재 냉장고에 있는 재료]
      ${_refrigeratorIngredients.join(', ')}
      
      위 재료들을 최대한 활용할 수 있는 레시피를 우선적으로 추천해줘. 
      냉장고에 있는 재료로 만들 수 있는 레시피를 우선적으로 선택하고, 
      필요한 추가 재료가 적은 레시피일수록 더 높은 우선순위를 줘.""";
    } else {
      _refrigeratorInfo = """
      
      현재 냉장고에 등록된 재료가 없습니다. 일반적인 레시피를 추천해줘.""";
    }

    final _prompt =
        """다음은 우리가 가진 전체 레시피 목록이야.
        이 목록을 보고 사용자에게 추천할 만한 레시피 최대 5개를 골라줘.
      $_tagInfo
      $_refrigeratorInfo
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
}