// 맛 태그 데이터 모델: 사용자 선호도 설정 및 레시피 필터링용 태그 정보 관리
class TagModel {
  // 태그명 (예: "매운맛", "달콤한맛", "짭짤한맛")
  final String name;
  // 사용자 선택 상태
  bool isSelected;

  TagModel(this.name, {this.isSelected = false});
}