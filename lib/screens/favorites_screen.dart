import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../services/recipe_service.dart'; // [추가] 1. 서비스 import

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // [추가] 2. 서비스 객체
  final RecipeService _service = RecipeService();
  List<Recipe> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _refreshList(); // [추가] 3. 초기 로드
  }

  // [추가] 4. 중앙 갱신 함수
  void _refreshList() {
    setState(() {
      // [수정] 5. 로직을 서비스에 위임
      _favoriteRecipes = _service.getFavoriteRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("즐겨찾기 목록"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _favoriteRecipes.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("아직 즐겨찾기한 레시피가 없어요.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _favoriteRecipes[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              ).then((_) {
                // [수정] 6. 돌아왔을 때 갱신
                _refreshList();
              });
            },
            child: RecipeCard(recipe: recipe),
          );
        },
      ),
    );
  }
}