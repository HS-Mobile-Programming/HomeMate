import 'package:flutter/material.dart';
import '../models/recipe.dart';

// 화면의 상태가 변해야 하므로 StatefulWidget으로 변경
class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late bool _isFavorite; // 현재 화면에서의 즐겨찾기 상태

  @override
  void initState() {
    super.initState();
    // 데이터를 받아와서 초기 상태 설정
    _isFavorite = widget.recipe.isFavorite;
  }

  // 별 버튼 눌렀을 때 실행되는 함수
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite; // 상태 반전 (True <-> False)
      widget.recipe.isFavorite = _isFavorite; // 원본 데이터에도 반영
    });

    // 하단에 안내 메시지(SnackBar) 띄우기
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
            // 1. 이미지 영역
            Container(
              height: 250,
              color: Colors.grey[300],
              //child: const Icon(Icons.rice_bowl, size: 100, color: Colors.white),
              // 실제 이미지가 있다면 아래 코드 사용
               child: widget.recipe.imageUrl.isNotEmpty
                  ? Image.network(widget.recipe.imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.rice_bowl, size: 100, color: Colors.white),
            ),

            // 2. 제목 및 즐겨찾기 버튼
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
                  // [핵심] 즐겨찾기 버튼
                  IconButton(
                    onPressed: _toggleFavorite,
                    iconSize: 40,
                    icon: Icon(
                      _isFavorite ? Icons.star : Icons.star_border, // 상태에 따라 아이콘 변경
                      color: _isFavorite ? Colors.amber : Colors.grey, // 상태에 따라 색상 변경
                    ),
                  ),
                ],
              ),
            ),

            // 3. 상세 정보 (난이도, 재료, 조리방법)
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
            const SizedBox(height: 40), // 하단 여백
          ],
        ),
      ),
    );
  }

  // 정보 박스 만드는 함수 (재사용)
  Widget _buildInfoSection(String title, String content) {
    return Container(
      color: const Color(0xFFE0F7FA), // 연한 하늘색 배경
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