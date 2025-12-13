import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../services/favorites_service.dart';
import '../widgets/recipe_image.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final RecipeService _recipeService = RecipeService();
  final FavoritesService _favoritesService = FavoritesService();

  // 현재 레시피의 즐겨찾기 여부 상태
  late bool _isFavorite;
  bool _isUpdating = false;

  // AI로 생성된 레시피인지 확인합니다 (ID가 'ai-generated-'로 시작하는지 체크)
  bool get _isAiGenerated => widget.recipe.id.startsWith('ai-generated-');

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite;
    _updateFavoriteStatus();
  }

  // 즐겨찾기 상태를 최신 정보로 업데이트합니다
  Future<void> _updateFavoriteStatus() async {
    if (_isUpdating) return;
    _isUpdating = true;
    try {
      final isFavorite = await _favoritesService.isFavorite(widget.recipe.id);
      if (mounted && _isFavorite != isFavorite) {
        setState(() {
          _isFavorite = isFavorite;
          widget.recipe.isFavorite = isFavorite;
        });
      }
    } finally {
      _isUpdating = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 표시될 때 즐겨찾기 상태를 업데이트
    _updateFavoriteStatus();
  }

  // 즐겨찾기 상태를 토글하고 스낵바로 피드백을 표시합니다
  Future<void> _toggleFavorite() async {
    await _recipeService.toggleFavorite(widget.recipe);
    setState(() {
      _isFavorite = widget.recipe.isFavorite;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? "즐겨찾기 등록" : "즐겨찾기 해제"),
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
            SizedBox(
              height: 250,
              child: RecipeImage(
                imageName: widget.recipe.imageName,
                width: double.infinity,
                height: 250,
              ),
            ),

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
                      if (!_isAiGenerated)
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

            _buildInfoSection(
              "재료",
              widget.recipe.ingredients
                  .map((ingredient) => ingredient.rawText)
                  .toList()
                  .join("\n"),
            ),
            const Divider(height: 1, thickness: 1),

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