// [WIDGET CLASS] - StatelessWidget
// 이 파일은 '재료 목록의 단일 항목' UI를 정의합니다.
// 'refrigerator_screen.dart'와 'home_screen.dart'에서 이 위젯을 재사용합니다.
//
// 'StatelessWidget' (상태가 없는 위젯):
// 이 위젯은 '스스로' 상태를 변경하지 않습니다.
// 'ingredient'나 'onEdit' 같은 '외부'에서 전달받은 값(파라미터)에 의해서만
// 화면이 그려집니다.

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
    DateTime? expiryDate = DateTime.tryParse(ingredient.expiryTime.replaceAll('.', '-'));

    // [수정] 기본값 설정
    Color cardColor = Colors.white;
    Color textColor = Colors.black;
    FontWeight fontWeight = FontWeight.normal;

    // [수정] applyExpiryColor가 true일 때만 색상 변경 로직을 실행합니다.
    if (expiryDate != null) {
      DateTime now = DateTime.now();
      final difference = expiryDate.difference(now).inDays;

      if (difference < 0) {
        // [수정] 유통기한 지남
        cardColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        fontWeight = FontWeight.bold;
      } else if (difference <= 1) {
        // [수정] 유통기한 1일 이하
        cardColor = Colors.yellow.shade100;
        textColor = Colors.yellow.shade900;
        fontWeight = FontWeight.bold;
      }
    }

    return Card(
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  Text(
                    "수량: ${ingredient.quantity.toString()}", // [오류 수정] quantity가 int이므로 toString() 추가
                    style: TextStyle(fontSize: 12, color: textColor.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            Text(
              ingredient.expiryTime,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: fontWeight,
              ),
            ),
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
