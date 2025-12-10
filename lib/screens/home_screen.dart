// 홈 대시보드: 오늘의 레시피·임박 재료 카드
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../services/refrigerator_service.dart';
import '../services/recipe_service.dart';
import '../widgets/ingredient_item.dart';
import '../widgets/recipe_image.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 냉장고 재료 서비스
  final RefrigeratorService _refrigeratorService = RefrigeratorService();
  // 레시피 서비스
  final RecipeService _recipeService = RecipeService();
  // 임박 재료 목록
  List<Ingredient> _expiringSoonIngredients = [];
  // 로딩 상태
  bool _isLoading = false;
  // 오늘의 레시피 페이지 인덱스
  int _currentPage = 0;
  // 페이지 컨트롤러
  final PageController _pageController = PageController(viewportFraction: 0.9);
  // 랜덤 레시피 목록
  List<Recipe> _randomRecipes = [];

  @override
  void initState() {
    super.initState();
    _refreshIngredients(); // 진입 시 임박 재료 로딩
    _loadRandomRecipes(); // 진입 시 랜덤 레시피 로딩
    alarm.addListener(_refreshIngredients); // 알람 발생 시 재료 새로고침
  }

  @override
  void dispose() {
    alarm.removeListener(_refreshIngredients); // 리스너 해제
    super.dispose();
  }

  // 랜덤 레시피 3개 로드
  Future<void> _loadRandomRecipes() async {
    final recipes = await _recipeService.getRandomRecipes(3);
    if (!mounted) return;
    setState(() {
      _randomRecipes = recipes;
    });
  }

  // 임박 재료 상위 5개 로드
  Future<void> _refreshIngredients() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final allIngredients = await _refrigeratorService.getAllIngredients();
    final sortedIngredients = _refrigeratorService.sortList(
      allIngredients,
      SortMode.expiryAsc,
    );

    if (!mounted) return;
    setState(() {
      _expiringSoonIngredients = sortedIngredients.take(5).toList();
      _isLoading = false;
    });
  }

  // 오늘의 레시피 인디케이터
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_randomRecipes.length, (index) {
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeIn,
            );
          },
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 오늘의 레시피
          const Text(
            "오늘의 레시피",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _randomRecipes.isEmpty
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : SizedBox(
                  height: 200,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _randomRecipes.length,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemBuilder: (context, index) {
                      final recipe = _randomRecipes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 레시피 이미지
                                  Expanded(
                                    child: RecipeImage(
                                      imageName: recipe.imageName,
                                      width: double.infinity,
                                      height: 120,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    recipe.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          if (_randomRecipes.isNotEmpty) _buildPageIndicator(),
          const SizedBox(height: 24),
          // 임박 재료 카드
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "유통기한 임박 재료",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_expiringSoonIngredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("임박한 재료가 없습니다!")),
                    )
                  else
                    Column(
                      children: _expiringSoonIngredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: IngredientItem(ingredient: ingredient),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
