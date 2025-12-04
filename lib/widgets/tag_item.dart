// [WIDGET CLASS] - StatelessWidget
// '선호도 설정' 화면의 '단일 태그' UI를 정의합니다.
// 'tags_screen.dart'의 'GridView' 내부에서 사용됩니다.

import 'package:flutter/material.dart';
import '../models/tag_model.dart';

class TagItem extends StatelessWidget {
  // [필드 (Fields) - 파라미터]

  // 'final TagModel tag':
  // 이 위젯이 표시할 '태그 데이터' 원본입니다. (예: "태그 A", isSelected: false)
  final TagModel tag;

  // 'final VoidCallback onTap':
  // 이 'TagItem' 위젯 전체가 '탭(클릭)'되었을 때 실행될 함수입니다.
  // (이 위젯은 '?'(Nullable)가 없으므로, 'onTap' 함수는 '반드시' 전달되어야 합니다.)
  final VoidCallback onTap;

  // [생성자 (Constructor)]
  const TagItem({
    super.key,
    required this.tag, // 'tag' 데이터는 필수
    required this.onTap, // 'onTap' 함수는 필수
  });

  // 태그 이름을 이미지 파일 경로로 변환하는 헬퍼 메서드
  String _getImagePath(String tagName) {
    // "60분 이상" -> "60분이상" (공백 제거)
    String fileName = tagName.replaceAll(' ', '');
    return 'assets/images/tags/$fileName.png';
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // Column: 자식 위젯들(원형 아이콘, 텍스트)을 세로(수직)로 배치합니다.
    return Column(
      children: [
        // InkWell: 자식 위젯(Container)이 '탭(onTap)' 이벤트를 받을 수 있게 해주고,
        //         '물결 효과(splash)'를 추가해줍니다.
        InkWell(
          onTap: onTap, // 'onTap' 파라미터로 받은 함수를 '탭' 이벤트에 연결
          // 'customBorder: const CircleBorder()':
          // InkWell의 물결 효과(splash)가 Container의 사각형 모양이 아닌
          // '원형(CircleBorder)'으로 퍼져나가도록 설정합니다.
          customBorder: const CircleBorder(),

          // Container: 원형 아이콘 영역을 정의합니다.
          child: Container(
            width: 64, // 가로 64 픽셀
            height: 64, // 세로 64 픽셀
            decoration: BoxDecoration(
              // 'shape: BoxShape.circle':
              // Container의 모양을 '원형'으로 만듭니다. (width/height가 같아야 완벽한 원)
              shape: BoxShape.circle,

              // [조건부 스타일링 (Ternary Operator)]
              // 'tag.isSelected ? (A) : (B)'
              // 'tag.isSelected' 값이 'true'이면 (A) 스타일을, 'false'이면 (B) 스타일을 적용합니다.
              color: tag.isSelected ? Colors.green.shade50 : const Color(0xFFEEEEEE),

              // [테두리]
              border: Border.all(
                // 0xFF2196F3: 진한 파란색 (선택됨)
                // Colors.transparent: 투명 (선택 안 됨 - 테두리 없음)
                color: tag.isSelected ? Colors.green : Colors.transparent,
                width: 2, // 테두리 두께
              ),
            ),

            // Image: 원형 Container '안'에 표시될 태그 이미지
            child: Image.asset(
              _getImagePath(tag.name),
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // 이미지가 없을 경우 기본 아이콘 표시
                return Icon(
                  Icons.collections,
                  color: tag.isSelected ? Colors.green : Colors.grey[600],
                  size: 32,
                );
              },
            ),
          ),
        ),
        // 원형 아이콘과 텍스트 사이의 수직 간격
        const SizedBox(height: 4),

        // [태그 이름]
        Text(
          tag.name, // 'tag' 데이터의 'name' 표시
          style: const TextStyle(fontSize: 14),
          textAlign: TextAlign.center, // (이름이 길어져 두 줄이 될 경우) 가운데 정렬
        ),
      ],
    );
  }
}