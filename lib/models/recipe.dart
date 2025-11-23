class Recipe {
  // DB 필드
  final String id;
  final String name;
  final String description;
  final String difficulty;
  final String cookTime;
  final String ingredients;
  final String step;
  final String tasteTags;
  final String imageName;

  // 앱 내부용 상태
  bool isFavorite;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.cookTime,
    required this.ingredients,
    required this.step,
    required this.tasteTags,
    required this.imageName,
    this.isFavorite = false,
  });

  // 재료 리스트 가져오기
  List<String> get ingredientList {
    return ingredients.split(',').map((e) => e.trim()).toList();
  }

  // 조리 순서 리스트 가져오기
  List<String> get stepList {
    return step.split('\n').map((e) => e.trim()).toList();
  }

  // 맛 태그 리스트 가져오기
  List<String> get tagList {
    return tasteTags.split(',').map((e) => e.trim()).toList();
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