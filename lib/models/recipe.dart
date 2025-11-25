// Recipe 모델
// Firestore의 레시피 문서와 1:1로 연결되는 데이터 모델입니다.
// 앱에서 레시피 목록 / 상세 화면을 표시할 때 사용합니다.
// 레시피의 원본 데이터는 Firestore에서 가져옵니다.

class Recipe {
  // Firestore에 저장된 필드
  final String id;                          // Firestore 문서 ID (예: "recipe_001")
  final String name;                        // 레시피 이름
  final String description;                 // 레시피 설명 (짧은 소개)
  final String difficulty;                  // 난이도 (초급/중급/고급)
  //final String cookTime;
  //final String ingredients;
  //final String step;
  //final String tasteTags;
  final int cookTimeMinutes;                // 조리 시간(분 단위)
  final List<RecipeIngredient> ingredients; // 재료 목록
  final List<String> steps;                 // 조리 단계
  final List<String> tasteTags;             // 맛 태그
  final String imageName;                   // 이미지 파일명 (예: "recipe_003.jpg")

  // 앱 내부에서만 사용하는 상태값 (DB에 저장되지 않음)
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    //required this.cookTime,
    required this.cookTimeMinutes,
    required this.ingredients,
    //required this.step,
    required this.steps,
    required this.tasteTags,
    required this.imageName,
    this.isFavorite = false,
  });

  // Firestore → Recipe 변환
  factory Recipe.fromJson(Map<String, dynamic> json, String id) {
    return Recipe(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cookTimeMinutes: json['cookTimeMinutes'] ?? 0,

      // 맛 태그는 Firestore에서 List<String> 형태로 저장됨
      tasteTags: List<String>.from(json['tasteTags'] ?? []),

      // 재료 목록(List<Map>) → List<RecipeIngredient>으로 변환
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => RecipeIngredient.fromJson(e))
          .toList(),

      // 조리 단계(List<String>)
      steps: List<String>.from(json['steps'] ?? []),

      imageName: json['imageName'] ?? '',
    );
  }

  // 앱 내부 저장용(캐시 및 오프라인 모드)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'cookTimeMinutes': cookTimeMinutes,
      'tasteTags': tasteTags,
      'ingredients': ingredients.map((e) => e.toMap()).toList(),
      'steps': steps,
      'imageName': imageName,
      'isFavorite': isFavorite,
    };
  }
}

// RecipeIngredient
// 레시피 내 "각 재료 1개"에 해당하는 구조입니다.
// Firestore 문서의 ingredients 배열 안의 한 아이템과 연결됩니다.
// 예:
// {
//    "rawText": "감자 2개",
//    "ingredientName": "감자"
// }
class RecipeIngredient {
  final String rawText; // 레시피 원문 재료 표현 (예: "감자 2개")

  // Firestore ingredients 사전에서 사용할 재료 이름
  // 레시피 추천, 냉장고 비교 등에 사용
  final String ingredientName;

  RecipeIngredient({
    required this.rawText,
    required this.ingredientName,
  });

  // JSON → RecipeIngredient
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      rawText: json['rawText'] ?? '',
      ingredientName: json['ingredientName'] ?? '',
    );
  }

  // RecipeIngredient → JSON
  Map<String, dynamic> toMap() {
    return {
      'rawText': rawText,
      'ingredientName': ingredientName,
    };
  }

  // Recipe 객체를 JSON 맵으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,'difficulty': difficulty,
      'cook_time': cookTime, // 모델의 필드명과 일치
      'ingredients': ingredients,
      'step': step,         // 모델의 필드명과 일치
      'taste_tags': tasteTags,
      'image_name': imageName,
    };
  }
}