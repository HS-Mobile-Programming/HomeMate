import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_screen.dart';

// 웹 스크롤을 위한 클래스
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [상태 변수]
  final RefrigeratorService _refrigeratorService = RefrigeratorService();
  final RecipeService _recipeService = RecipeService();

  List<Ingredient> _expiringSoonIngredients = [];
  List<Recipe> _recommendedRecipes = []; // [수정] 실제 Recipe 객체를 담도록 변경
  bool _isIngredientsLoading = false;
  bool _isRecipesLoading = false; // [추가] 레시피 로딩 상태

  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // [initState]
  @override
  void initState() {
    super.initState();

    // 데이터 로드 함수 호출
    _refreshIngredients();
    _refreshRecipes();
  }

  // [데이터 로드 함수]
  Future<void> _refreshIngredients() async {
    if (!mounted) return;
    setState(() => _isIngredientsLoading = true);

    var all = await _refrigeratorService.getAllIngredients();
    var sorted = _refrigeratorService.sortList(all, SortMode.expiryAsc);

    if (mounted) {
      setState(() {
        _expiringSoonIngredients = sorted.take(5).toList();
        _isIngredientsLoading = false;
      });
    }
  }

  // [추가] 추천 레시피 로드 함수
  Future<void> _refreshRecipes() async {
    if (!mounted) return;
    setState(() => _isRecipesLoading = true);

    // RecipeService를 통해 모든 레시피를 가져옵니다.
    var recipes = await _recipeService.getRecipes();

    if (mounted) {
      // [수정] 가져온 레시피 목록을 무작위로 섞습니다.
      recipes.shuffle();
      setState(() {
        // [수정] 섞인 레시피 중 3개만 화면에 표시하도록 제한합니다.
        _recommendedRecipes = recipes.take(3).toList();
        _isRecipesLoading = false;
      });
    }
  }

  // [UI 헬퍼 함수]
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_recommendedRecipes.length, (index) {
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

  // [build 메서드]
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 오늘의 레시피 (PageView) ---
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
              child: Text("오늘의 레시피", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // [수정] 로딩 및 데이터 상태에 따라 다른 UI 표시
            _isRecipesLoading
                ? const SizedBox(height: 190, child: Center(child: CircularProgressIndicator()))
                : _recommendedRecipes.isEmpty
                ? const SizedBox(height: 190, child: Center(child: Text("추천 레시피가 없습니다.")))
                : Column(
              children: [
                SizedBox(
                  height: 190, // [수정] PageView의 높이를 150으로 조정
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _recommendedRecipes.length,
                    onPageChanged: (int page) {
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (context, index) {
                      final recipe = _recommendedRecipes[index];
                      // [수정] Firebase Storage의 기본 URL과 이미지 이름을 조합
                      final imageUrl = 'https://firebasestorage.googleapis.com/v0/b/homemate-52d1b.appspot.com/o/recipes%2F${recipe.imageName}?alt=media';

                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            clipBehavior: Clip.antiAlias, // Card의 borderRadius를 자식(Image)에 적용
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // [수정] Image.asset -> Image.network 으로 변경
                                Expanded(
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    // 이미지 로딩 중에 보여줄 위젯
                                    loadingBuilder: (context, child, progress) {
                                      return progress == null ? child : const Center(child: CircularProgressIndicator());
                                    },
                                    // 이미지 로드 실패 시 보여줄 위젯
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported, size: 100, color: Colors.grey);
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(recipe.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                _buildPageIndicator(),
              ],
            ),
            const SizedBox(height: 24),

            // --- 유통기한 임박 목록 카드 ---
            Card(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 20),
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
                    _isIngredientsLoading
                        ? const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                        : _expiringSoonIngredients.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("임박한 재료가 없습니다!")),
                    )
                        : Column(
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
      ),
    );
  }
}
