// [WIDGET CLASS] - StatelessWidget
// 이 파일은 '재료 목록의 단일 항목' UI를 정의합니다.
// 'refrigerator_screen.dart'와 'home_screen.dart'에서 이 위젯을 재사용합니다.
//
// 'StatelessWidget' (상태가 없는 위젯):
// 이 위젯은 '스스로' 상태를 변경하지 않습니다.
// 'ingredient'나 'onEdit' 같은 '외부'에서 전달받은 값(파라미터)에 의해서만
// 화면이 그려집니다.

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/ingredient.dart';

class IngredientItem extends StatelessWidget {
  // [필드 (Fields) - 파라미터]
  // 이 위젯을 사용하는 부모(예: refrigerator_screen)로부터 '반드시' 받아야 하는 값들입니다.

  // 'final Ingredient ingredient':
  // 표시할 '재료 데이터' 원본입니다. (예: 계란, 10개, 2025.11.20)
  final Ingredient ingredient;

  // '수정' 아이콘을 눌렀을 때 실행될 '함수'입니다.
  final VoidCallback? onEdit;

  // [생성자 (Constructor)]
  // 'IngredientItem' 위젯을 생성할 때 호출됩니다.
  const IngredientItem({
    super.key, // 'key'는 플러터가 위젯을 식별하기 위한 고유 ID입니다.
    required this.ingredient, // 'ingredient'는 반드시 전달받아야 합니다.
    this.onEdit, // 'onEdit'은 선택적으로 전달받습니다 (null 가능).
  });

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // 1. 문자열("2025.11.20")을 날짜 객체(DateTime)로 변환
    DateTime? expiryDate = DateTime.tryParse(ingredient.expiryTime.replaceAll('.', '-'));

    // 카드 배경색 변수
    // 날짜 상태에 따라 배경색을 변경한다.
    // 기본값은 흰색
    Color cardColor = Colors.white;

    // 날짜 비교 로직
    if (expiryDate != null) {
      DateTime now = DateTime.now();

      if (isSameDay(expiryDate, now)) {
        // 유통기한이 오늘까지인 경우에는 배경색을 노란색으로 변경
        cardColor = Colors.yellow;
      } else if (expiryDate.isBefore(now)) {
        // 유통기간이 지난 경우에는 배경색을 빨간색으로 변경
        // (isSameDay 체크를 먼저 했으므로, 여기는 '오늘이 아니면서 과거인 경우'만 해당됨)
        cardColor = Colors.red;
      }
    }

    // Card: UI를 카드 형태로 감싸주는 위젯 (약간의 그림자와 둥근 모서리)
    return Card(
      color: cardColor,

      elevation: 1, // 그림자(음영)의 정도 (0은 그림자 없음)
      // 카드 모서리를 12 픽셀만큼 둥글게 처리
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 카드 위아래(vertical)로 4픽셀의 바깥쪽 여백(margin)을 줍니다.
      margin: const EdgeInsets.symmetric(vertical: 4),

      // Padding: Card '안'의 내용물(Child)에게 여백을 줍니다.
      child: Padding(
        // 가로(horizontal) 16, 세로(vertical) 8 픽셀의 안쪽 여백
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

        // Row: 자식 위젯들을 가로(수평)로 배치합니다.
        child: Row(
          children: [
            // Expanded: Row 안에서 '남은 모든 공간'을 차지합니다.
            // (이름/수량 영역이 최대한 확장하고, 유통기한/수정 버튼은 고정 폭을 가짐)
            Expanded(
              // Column: 자식 위젯들(이름, 수량)을 세로(수직)로 배치합니다.
              child: Column(
                // 'crossAxisAlignment': Column의 가로 정렬 방식
                // 'start': 왼쪽 정렬
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // [재료 이름]
                  Text(
                    ingredient.name, // 전달받은 'ingredient' 데이터의 'name'을 표시
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  // [재료 수량]
                  Text(
                    "수량: ${ingredient.quantity}", // 'quantity' 데이터를 표시
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // [유통기한]
            Text(
              ingredient.expiryTime, // 'expiryTime' 데이터를 표시
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),

            // [조건부 렌더링]
            // 'if (onEdit != null)' :
            // 생성자로부터 'onEdit' 함수가 'null'이 '아닌' 상태로 전달되었을 때만
            // '...' (Spread Operator) 뒤의 위젯 리스트([ ... ])를 이 자리에 포함시킵니다.
            // (만약 'home_screen'처럼 'onEdit'이 null이면, 이 부분은 렌더링되지 않습니다.)
            if (onEdit != null) ...[
              // const SizedBox(width: 8): 유통기한과 수정 버튼 사이의 가로 간격
              const SizedBox(width: 8),

              // IconButton: 아이콘만 있는 버튼
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Colors.grey), // '수정' 아이콘
                onPressed: onEdit, // 버튼이 '눌렸을 때' 실행할 함수 (생성자로부터 받은 'onEdit' 함수)
                // constraints/padding/splashRadius:
                // IconButton의 기본 크기(48x48)와 큰 여백을 제거하여
                // 버튼을 더 작고 콤팩트하게 만듭니다.
                constraints: const BoxConstraints(), // 크기 제약 최소화
                padding: const EdgeInsets.all(8), // 아이콘 주변 여백
                splashRadius: 20, // 물결 효과(splash) 반경
              ),
            ],
          ],
        ),
      ),
    );
  }
}