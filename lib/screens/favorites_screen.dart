// [SCREEN CLASS] - StatefulWidget
// '즐겨찾기 목록'을 보여주는 화면입니다.
// '마이페이지' 탭에서 '즐겨찾기' 메뉴를 누르면 이 화면으로 이동합니다.
//
// 'StatefulWidget':
// '즐겨찾기 목록(_favoriteRecipes)'을 '서비스'로부터 '불러와서'
// '상태'로 '스스로' 관리해야 하고,
// '상세' 화면에서 '돌아왔을 때' 이 목록을 '갱신'해야 하므로
// StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../services/recipe_service.dart'; // [추가] 1. 서비스 import

class FavoritesScreen extends StatefulWidget {
  // const FavoritesScreen(...): 위젯 생성자
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // [상태 변수 (State Variables)]

  //  2. 서비스 객체
  // '레시피' 로직(즐겨찾기 조회)을 담당하는 서비스 객체를 생성합니다.
  final RecipeService _service = RecipeService();

  // 화면에 표시될 '즐겨찾기된' 레시피 목록입니다.
  List<Recipe> _favoriteRecipes = [];

  // [추가] 로딩 상태 변수
  bool _isLoading = false;

  // [initState]
  // 화면이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    _refreshList(); //  3. 초기 로드 (처음 즐겨찾기 목록을 불러옴)
  }

  //  4. 중앙 갱신 함수
  // (RecipeScreen, RecommendationScreen의 _refreshList와 유사한 역할)
  Future<void> _refreshList() async {
    setState(() => _isLoading = true); // 로딩 시작

    // 'RecipeService'의 'getFavoriteRecipes' 로직을 호출하여
    // 'isFavorite == true'인 레시피 목록만 가져와서
    // '_favoriteRecipes' (상태 변수)에 '업데이트'합니다.
    var favorites = await _service.getFavoriteRecipes();

    if (mounted) {
      setState(() {
        _favoriteRecipes = favorites;
        _isLoading = false; // 로딩 종료
      });
    }
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar: 화면 상단 바 (MainScreen의 AppBar와 별개로 '새로' 가짐)
      appBar: AppBar(
        title: const Text("즐겨찾기 목록"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5), // 앱 공통 배경색

      // body: 화면 본문 영역
      // '_favoriteRecipes' (상태 변수)가 '비어있으면' (true) -> Center
      // '비어있지 않으면' (false) -> ListView
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteRecipes.isEmpty
          ? const Center( // [즐겨찾기가 없을 때 UI]
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          children: [
            Icon(Icons.star_border, size: 64, color: Colors.grey), // 빈 별 아이콘
            SizedBox(height: 16),
            Text("아직 즐겨찾기한 레시피가 없어요.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder( // [즐겨찾기가 있을 때 UI]
        padding: const EdgeInsets.all(16), // 목록 전체의 바깥쪽 여백
        itemCount: _favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _favoriteRecipes[index];
          // GestureDetector: '탭' 이벤트 처리
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // 'recipe' 파라미터로 '탭한 즐겨찾기 레시피' 전달
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              ).then((_) {
                // 6. 돌아왔을 때 갱신
                _refreshList();
              });
            },
            // 'RecipeCard' 위젯을 재사용합니다.
            child: RecipeCard(recipe: recipe),
          );
        },
      ),
    );
  }
}