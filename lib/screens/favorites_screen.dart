import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../services/recipe_service.dart';

// 즐겨찾기 레시피 목록 화면을 보여주는 StatefulWidget
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // 즐겨찾기 관련 로직을 담당하는 서비스
  final RecipeService _recipeService = RecipeService();

  // 화면에 표시할 즐겨찾기 레시피 목록 상태
  List<Recipe> _favoriteRecipes = [];

  // 데이터 로딩 여부 상태
  bool _isLoading = false;

  // 화면 최초 생성 시 즐겨찾기 목록을 불러오는 초기화 로직
  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // 즐겨찾기 목록을 새로 불러와 상태를 갱신하는 함수
  Future<void> _refreshList() async {
    setState(() => _isLoading = true);

    final favoriteList = await _recipeService.getFavoriteRecipes();

    if (mounted) {
      setState(() {
        _favoriteRecipes = favoriteList;
        _isLoading = false;
      });
    }
  }

  // 즐겨찾기 화면 UI를 구성하는 빌드 메서드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 앱바 구성
      appBar: AppBar(
        title: const Text("즐겨찾기 목록"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),

      // 본문: 로딩 중, 비어 있음, 목록 존재 3가지 상태 분기
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
          ? const Center(
              // 즐겨찾기가 없을 때 안내 UI
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "아직 즐겨찾기한 레시피가 없어요.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              // 즐겨찾기 목록 UI
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = _favoriteRecipes[index];

                // 레시피 카드 탭 시 상세 화면으로 이동 후 돌아오면 목록 갱신
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                      ),
                    ).then((_) => _refreshList());
                  },
                  child: RecipeCard(recipe: recipe),
                );
              },
            ),
    );
  }
}