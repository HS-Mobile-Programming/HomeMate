/// 표준 재료명과 다양한 표현 변형을 관리하는 재료 사전 모델 클래스
/// Firestore의 ingredients 컬렉션 문서와 1:1로 매핑됩니다
class IngredientDictionary {
  /// Firestore 문서 ID (표준 재료명)
  final String id;
  /// 표준화된 재료명
  final String name;
  /// 레시피에서 사용되는 다양한 표현 변형 (예: ["간장 1큰술", "진간장", "국간장"])
  final List<String> rawVariants;

  IngredientDictionary({
    required this.id,
    required this.name,
    required this.rawVariants,
  });

  /// Firestore 문서 데이터를 IngredientDictionary 객체로 변환합니다
  factory IngredientDictionary.fromFirestoreDocument(
    Map<String, dynamic> _data,
    String _documentId,
  ) {
    return IngredientDictionary(
      id: _documentId,
      name: _data['name'] ?? '',
      rawVariants: List<String>.from(_data['rawVariants'] ?? []),
    );
  }

  /// 로컬 캐시 데이터를 IngredientDictionary 객체로 변환합니다
  factory IngredientDictionary.fromJson(Map<String, dynamic> json, String id) {
    return IngredientDictionary(
      id: id,
      name: json['name'] ?? '',
      rawVariants: List<String>.from(json['rawVariants'] ?? []),
    );
  }

  /// 로컬 캐시 저장용 Map으로 변환합니다
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'rawVariants': rawVariants};
  }
}