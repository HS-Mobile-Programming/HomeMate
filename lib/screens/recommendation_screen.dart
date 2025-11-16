import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart'; // 1. 기존 'tags_screen.dart'를 import

// 정렬 상태
enum RecommendSortMode { nameAsc, nameDesc }

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  // 2. 자체적으로 임시 데이터 관리 (recipe_data.dart X)
  final List<Recipe> _allRecipes = [
    Recipe(
        title: "레시피 A (추천)", description: "AI가 추천한 볶음요리", imageUrl: "",
        difficulty: "쉬움"),
    Recipe(
        title: "레시피 B (추천)", description: "달콤하고 매콤한 국물요리", imageUrl: "",
        difficulty: "보통"),
    Recipe(
        title: "레시피 C (추천)", description: "빠르고 간단한 볶음요리", imageUrl: "",
        difficulty: "쉬움"),
  ];

  List<Recipe> _recommendedRecipes = [];
  RecommendSortMode _sortMode = RecommendSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    // (지금은 그냥 모든 레시피를 다 보여줌)
    _recommendedRecipes = _allRecipes;
    _sortList();
  }

  // 정렬 로직
  void _sortList() {
    setState(() {
      switch (_sortMode) {
        case RecommendSortMode.nameAsc:
          _recommendedRecipes.sort((a, b) => a.title.compareTo(b.title));
          break;
        case RecommendSortMode.nameDesc:
          _recommendedRecipes.sort((a, b) => b.title.compareTo(a.title));
          break;
      }
    });
  }

  // 정렬 버튼 UI
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert;
    String label;
    switch (_sortMode) {
      case RecommendSortMode.nameAsc: label = "이름 (가-힣)"; break;
      case RecommendSortMode.nameDesc: label = "이름 (힣-가)"; break;
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

  // (나중에 AI 로직 추가 시 사용할 함수)
  void _updateRecommendations() {
    // 예: final selectedTags = await Navigator.push(...);
    //     _recommendedRecipes = getAIRecipes(selectedTags, myIngredients);
    _sortList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 3. 상단 버튼 영역 (이미지 참고)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: () {
                        // 4. 'TagsScreen'으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TagsScreen()),
                        ).then((_) {
                          // (선호도 설정 후 돌아왔을 때)
                          _updateRecommendations();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(text: "추천", onPressed: () {
                      // (나중에 AI 추천 로직 실행)
                    }),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _sortMode = _sortMode == RecommendSortMode.nameAsc
                          ? RecommendSortMode.nameDesc
                          : RecommendSortMode.nameAsc;
                      _sortList();
                    });
                  },
                  child: _buildSortButtonChild(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 5. 추천 레시피 리스트
            Expanded(
              child: _recommendedRecipes.isEmpty
                  ? const Center(child: Text("추천 레시피가 없습니다."))
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
                      );
                    },
                    // 이미지처럼 민트색 배경 적용
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F7FA), // 민트색
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

  // 상단 버튼 스타일 (연보라색)
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