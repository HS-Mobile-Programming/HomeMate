// AI 기반 레시피 추천 서비스: Gemini AI를 활용한 사용자 선호 태그 및 냉장고 재료 기반 맞춤형 레시피 추천
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
      // [주의] pubspec.yaml에 assets/config/ 폴더가 등록되어 있어야 합니다.
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

  // ------------------------------------------------------------------------
  // 1. 기존 레시피 중에서 추천 (태그 + 냉장고 재료 반영)
  // ------------------------------------------------------------------------
  Future<List<Recipe>> getRecommendations({List<String>? selectedTags}) async {
    final List<String> _sortedTags;
    if (selectedTags != null && selectedTags.isNotEmpty) {
      _sortedTags = List<String>.from(selectedTags)..sort();
    } else {
      _sortedTags = <String>[];
    }

    // API 키 로드
    final apiKey = await _loadApiKey();
    if (apiKey.isEmpty) {
      debugPrint('[RecommendationService] API 키가 없어 추천을 수행할 수 없습니다.');
      return [];
    }

    final _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
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

    // 프롬프트 구성: 태그 정보
    String _tagInfo = "";
    if (_sortedTags.isNotEmpty) {
      _tagInfo = """
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
      _tagInfo = "사용자가 특별한 선호 태그를 설정하지 않았으므로, 다양한 레시피를 추천해줘.";
    }

    // 프롬프트 구성: 냉장고 재료 정보
    String _refrigeratorInfo = "";
    if (_refrigeratorIngredients.isNotEmpty) {
      _refrigeratorInfo = """
      [현재 냉장고에 있는 재료]
      ${_refrigeratorIngredients.join(', ')}
      위 재료들을 최대한 활용할 수 있는 레시피를 우선적으로 추천해줘. 
      냉장고에 있는 재료로 만들 수 있는 레시피를 우선적으로 선택하고, 
      필요한 추가 재료가 적은 레시피일수록 더 높은 우선순위를 줘.""";
    } else {
      _refrigeratorInfo = "현재 냉장고에 등록된 재료가 없습니다. 일반적인 레시피를 추천해줘.";
    }

    final _prompt = """
      다음은 우리가 가진 전체 레시피 목록이야.
      이 목록을 보고 사용자에게 추천할 만한 레시피 최대 5개를 골라줘.
      
      $_tagInfo
      
      $_refrigeratorInfo
      
      결과는 다른 설명 없이, 추천하는 레시피의 'id' 값만 쉼표(,)로 구분해서 알려줘.
      예를 들어, 'recipe-001,recipe-008,recipe-015' 와 같은 형식으로 응답해줘.

      [전체 레시피 목록]
      $_allRecipesJsonString
    """;

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

      // AI가 추천한 순서대로 정렬
      _recommendedRecipes.sort(
            (_a, _b) =>
        _recommendedIds.indexOf(_a.id) - _recommendedIds.indexOf(_b.id),
      );

      return _recommendedRecipes;
    } catch (e) {
      debugPrint("AI 추천 호출 오류: $e");
      return [];
    }
  }

  // ------------------------------------------------------------------------
  // 2. [복구됨] 검색어(재료)를 기반으로 Gemini에게 '새로운' 레시피 3개 생성 요청
  // ------------------------------------------------------------------------
  Future<List<Recipe>> getAiRecipesFromKeyword(String keyword) async {
    // API 키 로드
    final apiKey = await _loadApiKey();
    if (apiKey.isEmpty) {
      debugPrint('[RecommendationService] API 키가 없어 AI 검색을 수행할 수 없습니다.');
      return [];
    }

    final _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);

    // JSON 포맷을 강제하는 프롬프트
    final _prompt = """
    '$keyword'를 주재료로 하는 간단하고 맛있는 레시피 3개를 창작해서 추천해줘.
    
    결과는 반드시 아래와 같은 **순수 JSON 배열 형식**으로만 출력해줘. 마크다운(```json)이나 다른 설명은 절대 넣지 마.
    
    [
      {
        "name": "레시피 이름",
        "description": "한 줄 설명",
        "difficulty": "초급" 또는 "중급" 또는 "고급",
        "cookTimeMinutes": 20 (숫자만),
        "ingredients": ["재료1", "재료2"],
        "steps": ["1단계 설명", "2단계 설명"],
        "tasteTags": ["태그1", "태그2"]
      }
    ]
    """;

    final _content = [Content.text(_prompt)];

    try {
      final _response = await _model.generateContent(_content);
      String? _responseText = _response.text;

      if (_responseText == null) return [];

      // 혹시 모를 마크다운 제거
      _responseText = _responseText.replaceAll('```json', '').replaceAll('```', '').trim();

      final List<dynamic> _jsonList = jsonDecode(_responseText);
      final List<Recipe> _aiRecipes = [];

      for (int i = 0; i < _jsonList.length; i++) {
        final item = _jsonList[i];

        _aiRecipes.add(Recipe(
          id: 'ai-generated-$keyword-$i-${DateTime.now().millisecondsSinceEpoch}',
          name: item['name'] ?? 'AI 추천 레시피',
          description: item['description'] ?? '',
          difficulty: item['difficulty'] ?? '초급',
          cookTimeMinutes: item['cookTimeMinutes'] ?? 10,
          ingredients: List<String>.from(item['ingredients'] ?? [])
              .map((e) => RecipeIngredient(rawText: e, ingredientName: e))
              .toList(),
          steps: List<String>.from(item['steps'] ?? []),
          tasteTags: List<String>.from(item['tasteTags'] ?? []),
          imageName: '', // AI 레시피는 이미지가 없음 (기본 아이콘 표시됨)
          isFavorite: false,
        ));
      }

      return _aiRecipes;
    } catch (e) {
      debugPrint("AI 검색 생성 오류: $e");
      return [];
    }
  }

  // ------------------------------------------------------------------------
  // 3. [복구됨] RecipeService의 정렬 메서드 재사용 (화면에서 호출함)
  // ------------------------------------------------------------------------
  List<Recipe> sortRecipes(List<Recipe> _recipes, RecipeSortMode _mode) {
    return _recipeService.sortRecipes(_recipes, _mode);
  }
}