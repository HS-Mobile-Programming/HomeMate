import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefrigeratorService _service = RefrigeratorService();
  List<Ingredient> _expiringSoonIngredients = [];

  // 로딩 상태 변수
  bool _isLoading = false;

  // PageView를 위한 상태 변수 추가
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // 임시 추천 레시피 데이터
  final List<Map<String, String>> _recommendedRecipes = [
    {'name': '김치찌개', 'image': ''},
    {'name': '된장찌개', 'image': ''},
    {'name': '계란찜', 'image': ''},
  ];

  @override
  void initState() {
    super.initState();
    _refreshIngredients();
  }

  Future<void> _refreshIngredients() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    var all = await _service.getAllIngredients();
    var sorted = _service.sortList(all, SortMode.expiryAsc);

    if (mounted) {
      setState(() {
        _expiringSoonIngredients = sorted.take(5).toList();
        _isLoading = false;
      });
    }
  }

  // 페이지 인디케이터를 그리는 헬퍼 함수
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_recommendedRecipes.length, (index) {
        return Container(
          width: 8.0,
          height: 8.0,
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.withValues(alpha: 0.5),
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
          // --- 오늘의 레시피 (PageView) ---
          const Text("오늘의 레시피", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // PageView의 높이를 지정해야 합니다.
            child: PageView.builder(
              controller: _pageController,
              itemCount: _recommendedRecipes.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final recipe = _recommendedRecipes[index];
                // PageView에서는 각 페이지가 약간 보이도록 viewportFraction을 조절하고
                // 각 아이템에 마진을 주어 입체감을 더합니다.
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3), width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 이미지가 있으면 표시, 없으면 아이콘 표시
                          recipe['image']!.isNotEmpty
                              ? Image.asset('assets/images/${recipe['image']}', height: 120, fit: BoxFit.cover)
                              : const Icon(Icons.image, size: 100, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(recipe['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 페이지 인디케이터 추가
          _buildPageIndicator(),
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
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
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
