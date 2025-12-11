import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../services/recommendation_service.dart';
import '../services/recipe_service.dart'; // (정렬 enum 재사용)

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _service = RecommendationService();

  List<Recipe> _recommendedRecipes = [];
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  bool _isLoading = false;
  List<String> _savedTags = [];

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    setState(() => _isLoading = true);

    try {
      var recipes = await _service.getRecommendations(
        selectedTags: _savedTags.isEmpty ? null : _savedTags,
      );
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

  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
      _recommendedRecipes = _service.sortRecipes(_recommendedRecipes, _sortMode);
    });
  }

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
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: _onPreferencesPressed,
                    ),
                    const SizedBox(width: 8),
                    _buildTopButton(
                      text: "추천",
                      onPressed: _refreshList,
                    ),
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

  Widget _buildTopButton({required String text, required VoidCallback onPressed}) {
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