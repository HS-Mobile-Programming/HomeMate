// [SCREEN CLASS] - StatefulWidget
// '레시피 상세' 정보를 보여주는 화면입니다.
// 'RecipeScreen', 'RecommendationScreen', 'FavoritesScreen'에서
// 레시피 카드를 '탭'하면 이 화면으로 이동합니다.
//
// 'StatefulWidget':
// '즐겨찾기 상태(_isFavorite)'를 '스스로' 관리하고,
// 사용자가 '별(star)' 아이콘을 탭하면 이 상태를 '변경'해야 하므로
// StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  // [필드 (Field) - 파라미터]
  // 이 화면(위젯)을 '생성'할 때 '반드시' 전달받아야 하는 데이터입니다.
  final Recipe recipe;

  // const RecipeDetailScreen(...): 위젯 생성자
  // 'recipe' 파라미터를 '필수'로 받습니다.
  const RecipeDetailScreen({super.key, required this.recipe});

  // createState() : 이 위젯이 관리할 '상태(_RecipeDetailScreenState)' 객체를 생성합니다.
  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

// [_RecipeDetailScreenState]
// 'RecipeDetailScreen'의 실제 상태와 UI를 관리하는 클래스입니다.
class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // [상태 변수 (State Variables)]

  //  2. 서비스 객체
  // '레시피' 로직(즐겨찾기 토글)을 담당하는 서비스 객체를 생성합니다.
  final RecipeService _service = RecipeService();

  // '즐겨찾기' 아이콘의 현재 UI 상태를 저장합니다. (true: 꽉 찬 별, false: 빈 별)
  late bool _isFavorite;

  // [initState]
  // 이 위젯(화면)이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();

    // 'widget.recipe':
    // 'StatefulWidget'의 'State' 클래스(여기)에서는,
    // 'StatefulWidget' 클래스(RecipeDetailScreen)가 받은 파라미터(recipe)를
    // 'widget.' 접두사를 통해 접근할 수 있습니다.

    // '_isFavorite' (상태 변수)를
    // '부모로부터 전달받은 recipe 객체'의 '현재 isFavorite 값'으로 '초기화'합니다.
    _isFavorite = widget.recipe.isFavorite;
  }

  // [이벤트 핸들러]
  // '즐겨찾기(별)' 아이콘을 탭했을 때 호출되는 함수입니다.
  Future<void> _toggleFavorite() async { // [수정] async 추가

    await _service.toggleFavorite(widget.recipe); // [수정] await 추가
    // -> 'recipe_service'는 전달받은 'widget.recipe' 객체의
    //    'isFavorite' 값을 (true <-> false) '직접' 변경합니다.

    // UI 갱신
    // 'setState()': 플러터에게 "상태가 변경되었으니 화면을 다시 그려라"라고 알립니다.
    setState(() {
      // '서비스'에 의해 '이미 변경된' 'widget.recipe.isFavorite' 값을
      // 'UI 상태 변수(_isFavorite)'에도 '동기화'시킵니다.
      _isFavorite = widget.recipe.isFavorite;
      // -> 'build' 메서드가 다시 실행되면서,
      //    'Icon(_isFavorite ? Icons.star : Icons.star_border, ...)' 부분이
      //    새로운 '_isFavorite' 값에 맞는 아이콘(꽉 찬 별/빈 별)으로 변경됩니다.
    });

    // 스낵바를 띄워 사용자에게 피드백을 줍니다.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? "즐겨찾기에 등록되었습니다. ⭐" : "즐겨찾기가 해제되었습니다."),
          duration: const Duration(seconds: 1), // 1초간 표시
        ),
      );
    }
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: 화면 상단 바
      appBar: AppBar(
        title: const Text("레시피 상세"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // (title, leading 아이콘 색상)
        elevation: 0,
      ),

      // SingleChildScrollView: 상세 내용(재료, 조리법)이 길어질 경우 스크롤
      body: SingleChildScrollView(
        child: Column( // 위젯들을 세로(수직)로 배치
          crossAxisAlignment: CrossAxisAlignment.stretch, // '가로' 정렬: 'stretch' (꽉 채우기)
          // (이미지, 정보 섹션의 가로 폭을 화면에 맞게)
          children: [
            // [임시 이미지 영역]
            Container(
              height: 250, // 높이 250
              color: Colors.grey[300],
              child: const Icon(Icons.rice_bowl, size: 100, color: Colors.white),
            ),

            // [제목 및 즐겨찾기 버튼 영역]
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row( // 가로(수평) 배치
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                children: [
                  // Expanded: '제목(Text)'이 '즐겨찾기' 버튼 영역을
                  // '침범하지 않도록' 남은 공간만 차지하게 함
                  Expanded(
                    child: Text(
                      widget.recipe.title, // '전달받은' 레시피의 '제목' 표시
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // '즐겨찾기' 아이콘 버튼
                  IconButton(
                    onPressed: _toggleFavorite, //  5. 핸들러 연결
                    iconSize: 40, // 아이콘 크기
                    // '_isFavorite' (상태 변수) 값에 따라 아이콘 모양을 '동적'으로 변경
                    icon: Icon(
                      _isFavorite ? Icons.star : Icons.star_border, // true: 꽉 찬 별, false: 빈 별
                      // '_isFavorite' 값에 따라 아이콘 색상도 '동적'으로 변경
                      color: _isFavorite ? Colors.amber : Colors.grey, // true: 노란색, false: 회색
                    ),
                  ),
                ],
              ),
            ),

            // [정보 섹션]
            // '_buildInfoSection' 헬퍼 메서드를 사용하여
            // '난이도', '재료', '조리 방법' 섹션을 '반복' 생성
            _buildInfoSection("난이도", widget.recipe.difficulty),
            const Divider(height: 1, thickness: 1), // 섹션 구분선

            // 'widget.recipe.ingredients' (List<String>)를
            // '.join(", ")'을 사용해 "김치, 돼지고기, ..." (하나의 String)으로 합쳐서 전달
            _buildInfoSection(
                "재료",
                widget.recipe.ingredients.isNotEmpty ? widget.recipe.ingredients.join(", ") : "재료 정보 없음"
            ),
            const Divider(height: 1, thickness: 1),

            // 'widget.recipe.steps' (List<String>)를
            // '.asMap().entries.map(...).join("\n")'을 사용해
            // "1. 김치를 볶는다.\n2. 물을 붓는다.\n..." (번호가 매겨진 하나의 String)으로
            // '가공'하여 전달
            _buildInfoSection(
              "조리 방법",
              widget.recipe.steps.isNotEmpty
                  ? widget.recipe.steps.asMap().entries.map((e) => "${e.key + 1}. ${e.value}").join("\n")
                  : "조리 방법 정보 없음",
            ),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 (Helper Method)]
  // '반복되는 정보 섹션 UI'를 생성하는 함수입니다.
  Widget _buildInfoSection(String title, String content) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0), // 내부 여백
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // 제목
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)), // 내용
        ],
      ),
    );
  }
}