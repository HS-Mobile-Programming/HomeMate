// 레시피 데이터 모델: Firestore recipes 컬렉션 문서와 1:1 매핑되는 레시피 정보 및 사용자별 즐겨찾기 상태 관리

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

  // Firestore 문서 데이터를 Recipe 객체로 변환 (구버전 필드명 호환 포함)
  factory Recipe.fromFirestoreDocument(
    Map<String, dynamic> _data,
    String _documentId,
  ) {
    return Recipe(
      id: _documentId,
      name: _data['name'] ?? '',
      description: _data['description'] ?? '',
      difficulty: _data['difficulty'] ?? '',
      cookTimeMinutes:
          (_data['cookTimeMinutes'] ?? _data['cook_time'] ?? 0) as int,
      tasteTags: List<String>.from(
        _data['tasteTags'] ?? _data['taste_tags'] ?? [],
      ),
      ingredients: (_data['ingredients'] as List<dynamic>? ?? [])
          .map((_item) => RecipeIngredient.fromFirestoreDocument(_item))
          .toList(),
      steps: List<String>.from(_data['steps'] ?? _data['step'] ?? []),
      imageName: (_data['imageName'] ?? _data['image_name'] ?? '') as String,
    );
  }

  // 로컬 캐시 데이터를 Recipe 객체로 변환
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

  // 로컬 캐시 저장용 Map 변환
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

  // UI 표시용 조리 시간 문자열
  String get cookTime => '$cookTimeMinutes분';

  // UI 표시용 재료 텍스트 리스트
  List<String> get ingredientList =>
      ingredients.map((_item) => _item.rawText).toList();

  // UI 표시용 조리 단계 리스트
  List<String> get stepList => steps;

  // UI 표시용 맛 태그 리스트
  List<String> get tagList => tasteTags;

  // AI 추천 요청용 JSON 변환
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

// 레시피 재료 데이터 모델: 레시피 내 개별 재료 정보 및 표준 재료명 매핑
class RecipeIngredient {
  // 레시피 원문 재료 표현 (예: "감자 2개", "간장 1큰술")
  final String rawText;
  // 표준화된 재료명 (냉장고 재료 비교 및 추천 시스템용)
  final String ingredientName;

  RecipeIngredient({required this.rawText, required this.ingredientName});

  // Firestore 문서 데이터를 RecipeIngredient 객체로 변환
  factory RecipeIngredient.fromFirestoreDocument(Map<String, dynamic> _data) {
    return RecipeIngredient(
      rawText: _data['rawText'] ?? '',
      ingredientName: _data['ingredientName'] ?? '',
    );
  }

  // 로컬 캐시 데이터를 RecipeIngredient 객체로 변환
  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      rawText: json['rawText'] ?? '',
      ingredientName: json['ingredientName'] ?? '',
    );
  }

  // 로컬 캐시 저장용 Map 변환
  Map<String, dynamic> toMap() {
    return {'rawText': rawText, 'ingredientName': ingredientName};
  }

  // AI 추천 요청용 JSON 변환
  Map<String, dynamic> toJson() => toMap();
}