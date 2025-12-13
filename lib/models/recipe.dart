// 레시피 정보를 담는 모델 클래스
// Firestore의 recipes 컬렉션 문서와 1:1로 매핑되며, 사용자별 즐겨찾기 상태도 관리합니다
class Recipe {
  // Firestore 문서 ID
  final String id;
  // 레시피 이름
  final String name;
  // 레시피 설명
  final String description;
  // 난이도 (초급/중급/고급)
  final String difficulty;
  // 조리 시간 (분 단위)
  final int cookTimeMinutes;
  // 필요 재료 목록
  final List<RecipeIngredient> ingredients;
  // 조리 단계 설명 목록
  final List<String> steps;
  // 맛 태그 목록 (사용자 선호도 매칭용)
  final List<String> tasteTags;
  // Firebase Storage 이미지 파일명
  final String imageName;
  // 사용자별 즐겨찾기 상태 (Firestore users/{uid}/favorites에서 관리)
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.steps,
    required this.tasteTags,
    required this.imageName,
    this.isFavorite = false,
  });

  // 로컬 캐시 데이터를 Recipe 객체로 변환합니다
  factory Recipe.fromJson(Map<String, dynamic> json, String id) {
    return Recipe(
      id: id,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      difficulty: json['difficulty'] ?? '',
      cookTimeMinutes:
          (json['cookTimeMinutes'] ?? json['cook_time'] ?? 0) as int,
      tasteTags: List<String>.from(
        json['tasteTags'] ?? json['taste_tags'] ?? [],
      ),
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => RecipeIngredient.fromJson(e))
          .toList(),
      steps: List<String>.from(json['steps'] ?? json['step'] ?? []),
      imageName: (json['imageName'] ?? json['image_name'] ?? '') as String,
    );
  }

  // 로컬 캐시 저장용 Map으로 변환합니다
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'cookTimeMinutes': cookTimeMinutes,
      'tasteTags': tasteTags,
      'ingredients': ingredients.map((_item) => _item.toMap()).toList(),
      'steps': steps,
      'imageName': imageName,
      'isFavorite': isFavorite,
    };
  }

  // AI 추천 요청용 JSON으로 변환합니다
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'cookTimeMinutes': cookTimeMinutes,
      'tasteTags': tasteTags,
      'ingredients': ingredients.map((_item) => _item.toJson()).toList(),
      'steps': steps,
      'imageName': imageName,
    };
  }
}

// 레시피 내 개별 재료 정보를 담는 모델 클래스
// 정규화된 재료명을 통해 냉장고 재료와 비교하거나 추천 시스템에 사용됩니다
class RecipeIngredient {
  // 레시피 상세페이지의 재료 표시
  final String rawText;
  // 정규화된 재료명
  final String ingredientName;

  RecipeIngredient({required this.rawText, required this.ingredientName});

  // 로컬 캐시 데이터를 RecipeIngredient 객체로 변환합니다
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      rawText: json['rawText'] ?? '',
      ingredientName: json['ingredientName'] ?? '',
    );
  }

  // 로컬 캐시 저장용 Map으로 변환합니다
  Map<String, dynamic> toMap() {
    return {'rawText': rawText, 'ingredientName': ingredientName};
  }

  // AI 추천 요청용 JSON으로 변환합니다
  Map<String, dynamic> toJson() => toMap();
}