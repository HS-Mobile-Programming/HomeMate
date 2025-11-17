// [WIDGET CLASS] - StatelessWidget
// '레시피 목록의 단일 항목' UI를 정의합니다.
// 'recipe_screen.dart', 'recommendation_screen.dart', 'favorites_screen.dart'에서
// 이 위젯을 재사용합니다.

import 'package:flutter/material.dart';
// ../models/recipe.dart: 'Recipe' 모델(설계도)을 사용하기 위해 import 합니다.
import '../models/recipe.dart';

class RecipeCard extends StatelessWidget {
  // [필드 (Fields) - 파라미터]

  // 'final Recipe recipe':
  // 이 카드에 표시할 '레시피 데이터' 원본입니다. (예: 김치찌개, 매콤한...)
  final Recipe recipe;

  // [생성자 (Constructor)]
  const RecipeCard({
    super.key,
    required this.recipe, // 'recipe'는 반드시 전달받아야 합니다.
  });

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    // Card: UI를 카드 형태로 감싸줍니다.
    return Card(
      elevation: 4, // 그림자(음영) 정도 (IngredientItem의 1보다 진함)
      // 모서리를 16 픽셀만큼 둥글게 처리
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // 카드 바깥쪽으로 모든 방향(all) 8 픽셀의 여백
      margin: const EdgeInsets.all(8),

      // Column: 자식 위젯들(이미지 영역, 텍스트 영역)을 세로(수직)로 배치합니다.
      child: Column(
        // 'crossAxisAlignment': Column의 가로 정렬 방식
        // 'start': 왼쪽 정렬
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [이미지 영역]
          Container(
            height: 160, // 이미지 영역의 높이를 160 픽셀로 고정
            width: double.infinity, // 가로 폭은 카드(부모)의 폭을 '무한히' 차지 (즉, 꽉 채움)
            decoration: const BoxDecoration(
              color: Colors.grey, // (이미지 URL이 없으므로) 임시 회색 배경
              // 'borderRadius': 모서리를 둥글게 처리
              // 'vertical(top: ...)' : '위쪽(top)'의 '왼쪽(left)'과 '오른쪽(right)' 모서리만
              //                          Radius.circular(16)으로 깎습니다.
              // (카드의 둥근 모서리와 맞추기 위함)
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            // (임시 아이콘)
            child: const Icon(Icons.image, size: 50, color: Colors.white),
          ),

          // [텍스트 영역]
          Padding(
            // 안쪽 여백을 모든 방향(all)으로 16 픽셀 줍니다.
            padding: const EdgeInsets.all(16.0),

            // Column: 자식 위젯들(제목, 설명)을 세로로 배치합니다.
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
              children: [
                // [레시피 제목]
                Text(
                  recipe.title, // 'recipe' 데이터의 'title' 표시
                  // 'Theme.of(context).textTheme.titleLarge':
                  // 앱의 '테마(Theme)'에서 미리 정의된 'titleLarge' (큰 제목) 스타일을
                  // 가져와서 적용합니다.
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                // const SizedBox(height: 8): 제목과 설명 사이의 수직 간격
                const SizedBox(height: 8),

                // [레시피 설명]
                Text(
                  recipe.description, // 'recipe' 데이터의 'description' 표시
                  // 'Theme.of(context).textTheme.bodyMedium':
                  // 앱의 '테마(Theme)'에서 미리 정의된 'bodyMedium' (중간 본문) 스타일을
                  // 가져와서 적용합니다.
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}