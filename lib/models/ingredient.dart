class Ingredient {
  final String id;        // 새로 추가된 필드 (고유 ID)
  final String name;
  final String expiryTime;

  Ingredient({
    required this.id,     // 필수 이름 매개변수로 변경됨 ({})
    required this.name,
    required this.expiryTime,
  });
}