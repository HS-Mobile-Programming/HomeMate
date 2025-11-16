import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../services/recommendation_service.dart'; // [수정] 1. 추천 서비스
import '../services/recipe_service.dart'; // (정렬 enum 재사용)

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // [추가] 2. 서비스 객체
  final RecommendationService _service = RecommendationService();

  // [유지] 3. UI 상태 변수
  List<Recipe> _recommendedRecipes = [];
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;

  // [제거] 4. 데이터/로직 삭제
  // final List<Recipe> _allRecipes = [...] (삭제)
  // _updateRecommendations(), _sortList() (삭제)

  @override
  void initState() {
    super.initState();
    _refreshList(); // [추가] 5. 초기 로드
  }

  // [추가] 6. 중앙 갱신 함수
  void _refreshList() {
    setState(() {
      var recipes = _service.getRecommendations();
      _recommendedRecipes = _service.sortRecipes(recipes, _sortMode);
    });
  }

  // [추가] 7. 이벤트 핸들러
  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
    });
    _refreshList();
  }

  void _onPreferencesPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TagsScreen()),
    ).then((_) {
      // (선호도 설정값 기반으로 갱신)
      _refreshList();
    });
  }

  // (정렬 버튼 UI는 기존과 동일)
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert;
    String label;
    switch (_sortMode) {
      case RecipeSortMode.nameAsc: label = "이름 (가-힣)"; break;
      case RecipeSortMode.nameDesc: label = "이름 (힣-가)"; break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: _onPreferencesPressed, // [수정] 8. 핸들러 연결
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(text: "추천", onPressed: _refreshList),
                  ],
                ),
                TextButton(
                  onPressed: _onSortPressed, // [수정] 9. 핸들러 연결
                  child: _buildSortButtonChild(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _recommendedRecipes.isEmpty
                  ? const Center(child: Text("선호도에 맞는 추천 레시피가 없습니다."))
                  : ListView.builder(
                itemCount: _recommendedRecipes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                              recipe: _recommendedRecipes[index]
                          ),
                        ),
                      )
                      // [수정] 10. 돌아왔을 때 갱신 (즐겨찾기 상태 반영)
                          .then((_) => _refreshList());
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA),
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

  Widget _buildTopButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE6E6FA),
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}