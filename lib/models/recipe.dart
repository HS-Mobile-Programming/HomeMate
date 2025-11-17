class Recipe {
  final String title; // 레시피 제목
  final String description; // 레시피 요약 설명
  final String imageUrl; // 레시피 이미지 URL (현재 코드에서는 사용되지 않음)
  final String difficulty; // 난이도 (예: '쉬움', '보통')
  final List<String> ingredients; // 재료 목록 (예: ["김치", "돼지고기"])
  final List<String> steps; // 조리 단계 목록 (예: ["김치를 볶는다.", "물을 붓는다."])
  bool isFavorite;

  // [생성자 (Constructor)]
  Recipe({
    // 'required' 키워드: Recipe 객체를 생성할 때 이 값들(title, description, imageUrl)은
    // 반드시! 전달되어야 함을 의미합니다.
    required this.title,
    required this.description,
    required this.imageUrl,

    // '기본값 (Default Value)':
    this.difficulty = '보통',
    this.ingredients = const [],
    this.steps = const [],
    this.isFavorite = false,
  });
}