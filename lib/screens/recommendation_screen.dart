// [SCREEN CLASS] - StatefulWidget
// '추천' 탭 (index 3)에 표시되는 화면입니다.
// '선호도 설정' 버튼과 '정렬' 기능을 통해 '추천된' 레시피 목록을 보여줍니다.
//
// 'StatefulWidget':
// '정렬 모드(_sortMode)'와 '추천 결과(_recommendedRecipes)' 상태를
// '스스로' 관리해야 하므로 StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../services/recommendation_service.dart';
import '../services/recipe_service.dart'; // (정렬 enum 재사용)

class RecommendationScreen extends StatefulWidget {
  // const RecommendationScreen(...): 위젯 생성자
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // 추천 서비스 객체 - AI 기반 레시피 추천 로직을 담당
  final RecommendationService _service = RecommendationService();

  // 화면에 표시될 추천 레시피 목록
  List<Recipe> _recommendedRecipes = [];
  
  // 현재 정렬 방식 (기본값: 이름 오름차순)
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  
  // 로딩 상태 - 추천 요청 중일 때 true
  bool _isLoading = false;
  
  // 사용자가 선택한 태그 목록 - IndexedStack으로 탭 전환 시에도 유지됨
  List<String> _savedTags = [];

  @override
  void initState() {
    super.initState();
    // 화면 초기 진입 시 자동으로 추천 레시피 로드
    _refreshList();
  }

  /// 추천 레시피 목록을 새로고침하는 메서드
  /// - 저장된 태그를 기반으로 AI 추천을 받아옴
  /// - 태그가 없으면 일반 추천을 받음
  /// - 받아온 레시피를 현재 정렬 모드에 맞게 정렬하여 표시
  Future<void> _refreshList() async {
    setState(() => _isLoading = true);

    try {
      // AI 서비스를 통해 태그 기반 추천 레시피 받아오기
      var recipes = await _service.getRecommendations(
        selectedTags: _savedTags.isEmpty ? null : _savedTags,
      );
      // 현재 정렬 모드에 맞게 정렬
      var sortedRecipes = _service.sortRecipes(recipes, _sortMode);

      if (mounted) {
        setState(() {
          _recommendedRecipes = sortedRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("추천을 불러오는데 실패했습니다.")),
        );
      }
    }
  }

  /// 정렬 버튼 클릭 시 호출되는 메서드
  /// - 오름차순 ↔ 내림차순 토글
  /// - 이미 받아온 레시피 목록을 재정렬 (새로운 추천 요청 없음)
  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
      _recommendedRecipes = _service.sortRecipes(_recommendedRecipes, _sortMode);
    });
  }

  /// 선호도 설정 버튼 클릭 시 호출되는 메서드
  /// - TagsScreen으로 이동하여 태그 선택 화면 표시
  /// - 현재 저장된 태그를 초기값으로 전달
  /// - 사용자가 선택한 태그를 받아와서 _savedTags에 저장
  /// - 저장 후 자동 추천은 하지 않음 (사용자가 추천 버튼을 눌러야 함)
  void _onPreferencesPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagsScreen(
          initialSelectedTags: _savedTags,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _savedTags = result;
      });
    }
  }

  /// 정렬 버튼의 UI를 생성하는 헬퍼 메서드
  /// - 현재 정렬 모드에 따라 라벨 텍스트 변경
  /// - 아이콘과 텍스트를 가로로 배치
  Widget _buildSortButtonChild() {
    final label = _sortMode == RecipeSortMode.nameAsc ? "이름 (가-힣)" : "이름 (힣-가)";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.swap_vert, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상단 컨트롤 영역: 선호도 설정, 추천 버튼, 정렬 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // 선호도 설정 버튼 - 태그 선택 화면으로 이동
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: _onPreferencesPressed,
                    ),
                    const SizedBox(width: 8),
                    // 추천 버튼 - 새로운 추천 받기
                    _buildTopButton(
                      text: "추천",
                      onPressed: _refreshList,
                    ),
                  ],
                ),
                // 정렬 버튼 - 오름차순/내림차순 토글
                TextButton(
                  onPressed: _onSortPressed,
                  child: _buildSortButtonChild(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 추천 레시피 목록 영역
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendedRecipes.isEmpty
                  ? const Center(child: Text("선호도에 맞는 추천 레시피가 없습니다."))
                  : ListView.builder(
                itemCount: _recommendedRecipes.length,
                itemBuilder: (context, index) {
                  // 각 레시피 카드를 탭하면 상세 화면으로 이동
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                              recipe: _recommendedRecipes[index]
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: RecipeCard(recipe: _recommendedRecipes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 (Helper Method)]
  // '선호도 설정', '추천' 버튼처럼 '반복되는 상단 버튼 UI'를 생성하는 함수입니다.
  Widget _buildTopButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed, // 전달받은 'onPressed' 함수 연결
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade50, // 연보라색 배경
        foregroundColor: Colors.black, // 글자색 검정
        elevation: 0, // 그림자 없음
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}