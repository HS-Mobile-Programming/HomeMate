import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../services/recommendation_service.dart';
import '../services/recipe_service.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

// 추천 레시피 목록 화면 상태 관리
class _RecommendationScreenState extends State<RecommendationScreen> {
  // 추천 로직 처리 서비스
  final RecommendationService _recommendationService = RecommendationService();

  // 추천 결과 리스트
  List<Recipe> _recommendedRecipes = [];
  // 현재 정렬 기준 상태
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  // 추천 요청 중 로딩 상태
  bool _isLoading = false;
  // 사용자가 저장한 태그 목록
  List<String> _savedTags = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // 추천 목록 새로고침 및 정렬 적용
  Future<void> _refreshList() async {
    setState(() => _isLoading = true);

    try {
      final recipes = await _recommendationService.getRecommendations(
        selectedTags: _savedTags.isEmpty ? null : _savedTags,
      );
      final sortedRecipes = _recommendationService.sortRecipes(
        recipes,
        _sortMode,
      );

      if (mounted) {
        setState(() {
          _recommendedRecipes = sortedRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("추천을 불러오는데 실패했습니다.")));
      }
    }
  }

  // 정렬 버튼 클릭 시 오름/내림차순 전환
  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
      _recommendedRecipes = _recommendationService.sortRecipes(
        _recommendedRecipes,
        _sortMode,
      );
    });
  }

  // 태그 선호도 설정 화면 이동
  void _onPreferencesPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagsScreen(initialSelectedTags: _savedTags),
      ),
    );

    if (result != null) {
      setState(() {
        _savedTags = result;
      });
    }
  }

  // 정렬 버튼 라벨 구성
  Widget _buildSortButtonChild() {
    final sortLabel = _sortMode == RecipeSortMode.nameAsc
        ? "이름 (가-힣)"
        : "이름 (힣-가)";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.swap_vert, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(sortLabel, style: const TextStyle(color: Colors.black54)),
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
            // 상단 컨트롤 영역: 태그 설정, 추천 새로고침, 정렬 버튼 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: _onPreferencesPressed,
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(text: "추천", onPressed: _refreshList),
                  ],
                ),
                TextButton(
                  onPressed: _onSortPressed,
                  child: _buildSortButtonChild(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendedRecipes.isEmpty
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
                                  recipe: _recommendedRecipes[index],
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
                            child: RecipeCard(
                              recipe: _recommendedRecipes[index],
                            ),
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

  // 상단 공용 버튼 스타일 정의
  Widget _buildTopButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
