// IngredientDictionary 모델
// Firestore의 "ingredients" 컬렉션에 있는 데이터에 1:1로 대응하는 모델입니다.
// 레시피 rawText 재료를 표준 재료명(name)으로 매핑합니다.
// 사용자 냉장고 재료와 레시피 재료 비교 시 기준 데이터로 사용합니다.
// Firestore 구조 예시:
// {
//   "id": "간장",
//   "name": "간장",
//   "rawVariants": [
//     "간장 1/2숟갈",
//     "진간장 2큰술",
//     "양조간장 1T"
//   ]
// }

class IngredientDictionary {
  final String id;  // Firestore 문서 ID (예: "간장")
  final String name;  // 표준화된 재료 명칭

  // 레시피에서 등장할 수 있는 다양한 표현
  // 예: ["간장 1/2숟갈", "국간장", "양조간장 1T"]
  final List<String> rawVariants;

  IngredientDictionary({
    required this.id,
    required this.name,
    required this.rawVariants,
  });

  // Firestore JSON → 모델
  factory IngredientDictionary.fromJson(Map<String, dynamic> json, String id) {
    return IngredientDictionary(
      id: id,
      name: json['name'] ?? '',
      rawVariants: List<String>.from(json['rawVariants'] ?? []),
    );
  }

  // 로컬 저장용
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rawVariants': rawVariants,
    };
  }
}
