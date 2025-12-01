// [WIDGET CLASS] - StatelessWidget
// 이 파일은 '재료 목록의 단일 항목' UI를 정의합니다.
// 'refrigerator_screen.dart'와 'home_screen.dart'에서 이 위젯을 재사용합니다.
//
// 'StatelessWidget' (상태가 없는 위젯):
// 이 위젯은 '스스로' 상태를 변경하지 않습니다.
// 'ingredient'나 'onEdit' 같은 '외부'에서 전달받은 값(파라미터)에 의해서만 화면이 그려집니다.

import 'package:flutter/material.dart';
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
    // 1. 유통기한 문자열("2025.11.20")을 DateTime 객체로 변환합니다.
    // .replaceAll('.', '-')는 "2025.11.20" 형식을 "2025-11-20"으로 바꿔서 파싱 오류를 방지합니다.
    DateTime? expiryDate = DateTime.tryParse(ingredient.expiryTime.replaceAll('.', '-'));

    // 2. UI에 적용할 색상, 글자 스타일, D-day 텍스트를 담을 변수를 미리 선언합니다.
    Color cardColor = Colors.white; // 카드 배경색 (기본값: 흰색)
    Color textColor = Colors.black; // 글자색 (기본값: 검은색)
    FontWeight fontWeight = FontWeight.normal; // 글자 굵기 (기본값: 보통)
    String dDayText = ''; // D-day 텍스트 (기본값: 비어있음)

    // 3. 유통기한 날짜(expiryDate)가 유효할 경우에만 D-day 계산 및 스타일 변경 로직을 실행합니다.
    if (expiryDate != null) {
      // D-day를 정확히 계산하기 위해, 현재 시간의 시/분/초를 제외한 '오늘 날짜'를 구합니다.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final expiryDateOnly = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

      // '오늘'과 '유통기한 날짜'의 차이를 '일(day)' 단위로 계산합니다.
      final difference = expiryDateOnly.difference(today).inDays;

      if (difference < 0) {
        // 유통기한이 지났을 경우 (음수)
        cardColor = Colors.red.shade100; // 배경: 연한 빨강
        textColor = Colors.red.shade900; // 글자: 진한 빨강
        fontWeight = FontWeight.bold; // 글자: 굵게
        dDayText = 'D+${-difference}'; // 예: -2일 -> D+2
      } else if (difference == 0) {
        // 유통기한이 오늘까지일 경우
        cardColor = Colors.orange.shade100; // 배경: 연한 주황
        textColor = Colors.orange.shade900; // 글자: 진한 주황
        fontWeight = FontWeight.bold; // 글자: 굵게
        dDayText = 'D-DAY';
      } else if (difference <= 3) {
        // 유통기한이 1~3일 남았을 경우
        cardColor = Colors.yellow.shade100; // 배경: 연한 노랑
        textColor = Colors.orange.shade500; // 글자: 노랑
        fontWeight = FontWeight.bold; // 글자: 굵게
        dDayText = 'D-$difference'; // 예: 2일 -> D-2
      } else {
        // 유통기한이 4일 이상 남았을 경우
        dDayText = 'D-$difference'; // D-day 텍스트만 설정
      }
    }

    // Card: UI를 카드 형태로 감싸주는 위젯입니다.
    return Card(
      color: cardColor, // 위에서 계산된 카드 배경색 적용
      elevation: 1, // 그림자(음영)의 정도
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),

      // Padding: Card '안'의 내용물에게 여백을 줍니다.
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        // Row: 자식 위젯들을 가로(수평)로 배치합니다.
        child: Row(
          children: [
            // Expanded: 이름/수량 영역이 남은 공간을 모두 차지하도록 합니다.
            Expanded(
              // Column: 재료 이름과 수량을 세로로 배치합니다.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 자식들을 왼쪽 정렬
                children: [
                  // 재료 이름
                  Text(
                    ingredient.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  // 재료 수량
                  Text(
                    "수량: ${ingredient.quantity.toString()}",
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),

            // 유통기한과 D-day를 함께 표시하기 위해 Column으로 묶습니다.
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, // 오른쪽 정렬
              children: [
                // 유통기한
                Text(
                  ingredient.expiryTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
                // D-day 텍스트가 비어있지 않을 경우에만 표시합니다.
                if (dDayText.isNotEmpty)
                  Text(
                    dDayText,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),

            // 수정 버튼 (onEdit 함수가 전달된 경우에만 보임)
            if (onEdit != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.edit, size: 20, color: Colors.grey.shade600),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
