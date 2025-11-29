import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart'; // Firestore 기반 레시피 로딩으로 전환
import 'recipe_service.dart'; // 정렬 모드(enum) 재사용

class RecommendationService {

  // --- 1. Gemini AI 설정 ---
  // 여기에 발급받은 Gemini API 키를 입력하세요.
  // 보안을 위해 실제 앱에서는 환경 변수나 별도의 키 관리 서비스를 사용하는 것이 좋습니다.
  // [주의] Git에 올릴 때는 이 키를 지우고 올리는 것이 안전합니다.
  static const String _apiKey = ""; // <--- 여기에 API 키를 입력하세요

  final RecipeService _recipeService = RecipeService();

  // [추가] 추천받은 레시피 목록을 임시로 저장할 변수 (캐시)
  // static으로 선언하여 앱이 실행되는 동안 데이터가 메모리에 유지되도록 합니다.
  // (화면을 나갔다 와도 데이터가 남아있게 됨)
  static List<Recipe>? _cachedRecipes;

  // --- 2. 추천 레시피 조회 로직 ---
  Future<List<Recipe>> getRecommendations() async {

    // [수정] 캐시 확인 로직 추가
    // 만약 이전에 저장해둔 데이터(_cachedRecipes)가 있다면,
    // AI를 호출하지 않고 저장된 데이터를 즉시 반환합니다. (API 호출 절약, 로딩 시간 단축)
    if (_cachedRecipes != null) {
      return _cachedRecipes!;
    }

    // --- 캐시가 없다면(null), 아래 AI 호출 로직을 실행합니다 ---

    // AI 모델 초기화
    final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

    // Firestore에서 전체 레시피 불러옵니다.
    final allRecipes = await _recipeService.getRecipes();

    // AI에게 전달할 전체 레시피 목록을 JSON 형식의 문자열로 변환
    final allRecipesJsonString = jsonEncode(allRecipes.map((r) => r.toJson()).toList());

    // 태그 정보를 프롬프트에 포함
    String tagInfo = "";
    if (sortedTags.isNotEmpty) {
      tagInfo = """
      
      [사용자 선호 태그]
      ${sortedTags.join(', ')}
      
      위 태그들을 고려하여 추천해줘. 태그에 맞는 레시피를 우선적으로, 랜덤하게 추천해줘
      """;

      // 난이도 태그 처리
      final difficultyTags = sortedTags.where((tag) => ['초급', '중급', '고급'].contains(tag)).toList();
      if (difficultyTags.isNotEmpty) {
        tagInfo += "\n- 난이도: ${difficultyTags.join(', ')}를 선호합니다.\n";
      }

      // 조리시간 태그 처리
      final timeTags = sortedTags.where((tag) => ['15분', '30분', '60분 이상'].contains(tag)).toList();
      if (timeTags.isNotEmpty) {
        tagInfo += "- 조리시간: ${timeTags.join(', ')}의 레시피를 선호합니다.\n";
      }
    } else {
      tagInfo = """
      
      사용자가 특별한 선호 태그를 설정하지 않았으므로, 다양한 레시피를 추천해줘.
      """;
    }

    // AI에게 보낼 프롬프트(명령어) 구성
    final prompt = """
      다음은 우리가 가진 전체 레시피 목록이야. 이 목록을 보고 사용자에게 추천할 만한 레시피 최대 5개를 골라줘.
      $tagInfo
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

      // [추가] API 호출로 받아온 데이터를 캐시 변수에 저장
      // 다음 번 호출 때는 이 변수에 있는 값을 바로 사용하게 됩니다.
      _cachedRecipes = recommendedRecipes;

      return recommendedRecipes;

    } catch (e) {
      // API 호출 중 오류 발생 시 처리
      print("AI 호출 에러: $e"); // [추가] 디버깅을 위해 에러 로그 출력
      // 오류 발생 시 사용자에게 빈 리스트를 보여주거나, 다른 대체 로직을 수행할 수 있습니다.
      // throw Exception('레시피 추천을 받아오는 데 실패했습니다.');
      return []; // [수정] 에러 발생 시 앱이 죽지 않도록 빈 리스트 반환으로 변경
    }
  }

  // [추가] 캐시 초기화 메서드
  // 사용자가 '추천' 버튼을 누르거나 '선호도'를 변경했을 때,
  // 저장된 데이터를 지워서 강제로 새로운 추천을 받도록 할 때 사용합니다.
  void clearCache() {
    _cachedRecipes = null;
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