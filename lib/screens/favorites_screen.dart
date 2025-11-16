// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import '../data/recipe_data.dart'; // 공용 데이터
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Recipe> _favoriteRecipes = [];

  @override
  void initState() {
    super.initState();
    _updateFavoritesList();
  }

  // 리스트 갱신 함수
  void _updateFavoritesList() {
    setState(() {
      _favoriteRecipes = allRecipes.where((r) => r.isFavorite).toList();
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
                // [핵심] 상세 화면에서 즐겨찾기를 해제하고 돌아왔을 때
                // 이 화면의 리스트를 갱신
                _updateFavoritesList();
              });
            },
            child: RecipeCard(recipe: recipe),
          );
        },
      ),
    );
  }
}