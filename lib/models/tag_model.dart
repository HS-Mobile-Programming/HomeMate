// 사용자 선호도 설정 및 레시피 필터링에 사용되는 맛 태그 정보를 담는 모델 클래스
class TagModel {
  // 태그명
  final String name;
  // 사용자가 선택한 상태인지 여부
  bool isSelected;

  TagModel(this.name, {this.isSelected = false});
}