import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // 레시피 즐겨찾기 토글을 담당하는 서비스 인스턴스
  final RecipeService _recipeService = RecipeService();

  // 현재 레시피의 즐겨찾기 여부 상태
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite;
  }

  // 즐겨찾기 상태를 토글하고 스낵바로 피드백을 표시하는 메서드
  Future<void> _toggleFavorite() async {
    await _recipeService.toggleFavorite(widget.recipe);
    setState(() {
      _isFavorite = widget.recipe.isFavorite;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? "즐겨찾기 등록 ⭐" : "즐겨찾기 해제"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 레시피 제목을 표시하는 상단 앱바
        title: Text(widget.recipe.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 레시피 대표 이미지를 전체 폭으로 표시하는 영역
            SizedBox(
              height: 250,
              child: RecipeImage(
                imageName: widget.recipe.imageName,
                width: double.infinity,
                height: 250,
              ),
            ),

            // 레시피 제목, 설명, 즐겨찾기 버튼, 태그를 포함하는 정보 영역
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.recipe.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _toggleFavorite,
                        iconSize: 40,
                        icon: Icon(
                          _isFavorite ? Icons.star : Icons.star_border,
                          color: _isFavorite ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.recipe.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // 맛 관련 태그를 칩 형태로 나열하는 영역
                  Wrap(
                    spacing: 8,
                    children: widget.recipe.tasteTags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: Colors.green.shade50,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),

            // 조리 시간, 난이도 등 기본 정보를 보여주는 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildIconInfo(
                    Icons.timer,
                    "시간",
                    "${widget.recipe.cookTimeMinutes}분",
                  ),
                  _buildIconInfo(
                    Icons.restaurant,
                    "난이도",
                    widget.recipe.difficulty,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // 재료 목록을 줄바꿈으로 표시하는 영역
            _buildInfoSection(
              "재료",
              widget.recipe.ingredients
                  .map((ingredient) => ingredient.rawText)
                  .toList()
                  .join("\n"),
            ),
            const Divider(height: 1, thickness: 1),

            // 조리 단계를 순서대로 보여주는 영역
            _buildInfoSection(
              "조리 방법",
              widget.recipe.steps.isNotEmpty
                  ? widget.recipe.steps.join("\n\n")
                  : "조리 방법 정보 없음",
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // 아이콘과 레이블, 값을 세로로 정렬해 보여주는 정보 위젯
  Widget _buildIconInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // 제목과 본문을 묶어 섹션 형태로 보여주는 위젯
  Widget _buildInfoSection(String title, String content) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}
