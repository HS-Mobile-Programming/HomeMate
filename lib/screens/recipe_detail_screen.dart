import 'package:flutter/material.dart';
import '../models/recipe.dart';

// [수정] StatelessWidget -> StatefulWidget
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool _isFavorite; // 화면 내부에서 쓸 상태 변수

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe.isFavorite; // 공용 데이터의 상태로 초기화
  }

  // 별 버튼 토글 함수
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
      // [핵심] 공용 데이터(원본)의 상태를 직접 변경
      widget.recipe.isFavorite = _isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorite ? "즐겨찾기에 등록되었습니다. ⭐" : "즐겨찾기가 해제되었습니다."),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("레시피 상세"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[300],
              child: const Icon(Icons.rice_bowl, size: 100, color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.recipe.title,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // [수정] 즐겨찾기 버튼
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
            ),

            _buildInfoSection("난이도", widget.recipe.difficulty),
            const Divider(height: 1, thickness: 1),
            _buildInfoSection("재료", widget.recipe.ingredients.isNotEmpty ? widget.recipe.ingredients.join(", ") : "재료 정보 없음"),
            const Divider(height: 1, thickness: 1),
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

  Widget _buildInfoSection(String title, String content) {
    return Container(
      color: const Color(0xFFE0F7FA),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      ),
    );
  }
}