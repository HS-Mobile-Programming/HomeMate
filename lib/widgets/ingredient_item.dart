// 재료 항목 위젯
// 냉장고 및 홈 화면의 재료 목록 개별 항목 UI, 유통기한 D-day 계산 및 시각적 경고 표시
import 'package:flutter/material.dart';
import '../models/ingredient.dart';

class IngredientItem extends StatelessWidget {
  // 표시할 재료 데이터
  final Ingredient ingredient;
  // 수정 버튼 탭 이벤트 핸들러
  final VoidCallback? onEdit;

  const IngredientItem({super.key, required this.ingredient, this.onEdit});

  @override
  Widget build(BuildContext context) {
    // 유통기한 문자열을 DateTime 객체로 변환
    DateTime? _expiryDate = DateTime.tryParse(
      ingredient.expiryTime.replaceAll('.', '-'),
    );

    // UI 스타일 변수 초기화
    Color _cardColor = Colors.white;
    Color _textColor = Colors.black;
    FontWeight _fontWeight = FontWeight.normal;
    String _dDayText = '';

    // 유통기한 기반 D-day 계산 및 UI 스타일 설정
    if (_expiryDate != null) {
      final _now = DateTime.now();
      final _today = DateTime(_now.year, _now.month, _now.day);
      final _expiryDateOnly = DateTime(
        _expiryDate.year,
        _expiryDate.month,
        _expiryDate.day,
      );

      final _daysRemaining = _expiryDateOnly.difference(_today).inDays;

      if (_daysRemaining < 0) {
        _cardColor = Colors.red.shade100;
        _textColor = Colors.red.shade900;
        _fontWeight = FontWeight.bold;
        _dDayText = 'D+${-_daysRemaining}';
      } else if (_daysRemaining == 0) {
        _cardColor = Colors.orange.shade100;
        _textColor = Colors.orange.shade900;
        _fontWeight = FontWeight.bold;
        _dDayText = 'D-DAY';
      } else if (_daysRemaining <= 3) {
        _cardColor = Colors.yellow.shade100;
        _textColor = Colors.orange.shade500;
        _fontWeight = FontWeight.bold;
        _dDayText = 'D-$_daysRemaining';
      } else {
        _dDayText = 'D-$_daysRemaining';
      }
    }

    return Card(
      color: _cardColor,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  Text(
                    "수량: ${ingredient.quantity.toString()}",
                    style: TextStyle(
                      fontSize: 12,
                      color: _textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ingredient.expiryTime,
                  style: TextStyle(
                    fontSize: 14,
                    color: _textColor,
                    fontWeight: _fontWeight,
                  ),
                ),
                if (_dDayText.isNotEmpty)
                  Text(
                    _dDayText,
                    style: TextStyle(
                      fontSize: 12,
                      color: _textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
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