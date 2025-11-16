import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../data/recipe_data.dart'; // [추가] 공용 데이터 import

enum RecommendSortMode { nameAsc, nameDesc }

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {


  List<Recipe> _recommendedRecipes = [];
  RecommendSortMode _sortMode = RecommendSortMode.nameAsc;

  @override
  void initState() {
    super.initState();
    _updateRecommendations(); // 추천 목록 갱신
  }

  void _updateRecommendations() {
    setState(() {
      // [수정] 공용 데이터로 추천 로직 실행
      _recommendedRecipes = allRecipes.where((r) => r.difficulty == "쉬움").toList();

      // --- [미래에 할 일] ---
      // 1. TagsScreen에서 고른 선호도 태그 가져오기
      // 2. RefrigeratorScreen의 allIngredients (보유 재료) 가져오기
      // 3. 이 두 정보를 AI 모델에 전달
      // 4. AI가 추천해준 '진짜 추천 목록'을 받음
      // _recommendedRecipes = ai_결과_리스트;
      // -----------------------
      _sortList();
    });
  }

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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TagsScreen()),
                        ).then((_) {
                          _updateRecommendations();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(text: "추천", onPressed: () {}),
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
                          .then((_) => setState(() { _updateRecommendations(); }));
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