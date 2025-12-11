// 사용자 냉장고 재료 데이터 모델: Firestore users/{uid}/ingredients 컬렉션 문서와 1:1 매핑되는 재료 정보 관리
class Ingredient {
  // Firestore 문서 ID (타임스탬프 기반 고유 ID)
  final String id;
  // 재료명
  final String name;
  // 재료 수량
  final int quantity;
  // 유통기한 (yyyy.MM.dd 형식)
  final String expiryTime;

  Ingredient({
    required this.id,
    required this.name,
    this.quantity = 1,
    required this.expiryTime,
  });
}