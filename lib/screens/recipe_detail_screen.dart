import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _service = RecipeService();
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite;
  }

  Future<void> _toggleFavorite() async {
    await _service.toggleFavorite(widget.recipe);
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
        title: Text(widget.recipe.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 이미지 영역
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.rice_bowl, size: 100, color: Colors.white),
            ),

            // 제목과 정보 영역
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
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                  Text(widget.recipe.description, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 16),

                  // [태그 표시]
                  Wrap(
                    spacing: 8,
                    // tagList getter 사용
                    children: widget.recipe.tasteTags.map((tag) => Chip(
                      label: Text(tag),
                      backgroundColor: Colors.green.shade50,
                    )).toList(),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),

            // 기본 정보
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //_buildIconInfo(Icons.timer, "시간", widget.recipe.cookTime),
                  _buildIconInfo(Icons.timer, "시간", "${widget.recipe.cookTimeMinutes}분"),
                  _buildIconInfo(Icons.restaurant, "난이도", widget.recipe.difficulty),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            // 재료
            _buildInfoSection(
                "재료",
                //widget.recipe.ingredientList.join("\n") // 줄바꿈으로 보여주기
                widget.recipe.ingredients.map((e) => e.rawText).toList().join("\n")
            ),
            const Divider(height: 1, thickness: 1),

            // 조리 방법
            _buildInfoSection(
              "조리 방법",
              /*
              widget.recipe.stepList.isNotEmpty
                  ? widget.recipe.stepList.join("\n\n") // 단계별로 간격 두기
              */
              widget.recipe.steps.isNotEmpty
                  ? widget.recipe.steps.join("\n\n") // 단계별로 간격 두기
                  : "조리 방법 정보 없음",
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.6)),
        ],
      ),
    );
  }
}