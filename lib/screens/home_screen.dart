import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

// [StatefulWidget]
// '홈' 탭 (가장 첫 화면) UI를 정의합니다.
// StatefulWidget은 화면의 내용(데이터)이 사용자의 행동에 따라 변경되어야 할 때 사용합니다.
// (예: 서버에서 데이터를 불러오면 화면이 업데이트되어야 함)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [상태 변수 (State Variables)]
  // 이 변수들의 값이 바뀌고 'setState'가 호출되면 화면이 다시 그려집니다.

  // RefrigeratorService 클래스의 인스턴스(실제 객체)를 생성합니다.
  // 앞으로 재료 데이터를 처리할 때는 이 객체를 사용합니다.
  final RefrigeratorService _service = RefrigeratorService();

  // 레시피 서비스 객체 (랜덤 레시피 로딩용)
  final RecipeService _recipeService = RecipeService();

  // 화면에 표시될 '유통기한 임박' 재료 목록을 담는 리스트입니다.
  List<Ingredient> _expiringSoonIngredients = [];

  // 데이터를 불러오는 동안 로딩 스피너를 표시하기 위한 상태 변수입니다.
  bool _isLoading = false;

  // PageView의 현재 페이지 번호를 저장하는 변수입니다. (0부터 시작)
  int _currentPage = 0;

  // PageView를 제어하기 위한 컨트롤러입니다.
  // viewportFraction: 0.9는 각 페이지가 화면의 90% 너비를 차지하게 하여,
  // 양 옆의 다른 페이지가 살짝 보이도록 만드는 효과를 줍니다.
  final PageController _pageController = PageController(viewportFraction: 0.9);

  // '오늘의 레시피' PageView에 보여줄 랜덤 데이터
  List<Recipe> _randomRecipes = [];

  // [initState]
  // 이 위젯(화면)이 화면을 호출하는 함수.
  @override
  void initState() {
    super.initState();
    _refreshIngredients(); // 화면이 처음 뜰 때 데이터를 불러오도록 함수 호출
    _loadRandomRecipes();
    alarm.addListener(_refreshIngredients); // 알람이 울리면 화면 다시 호출
  }

  Future<void> _loadRandomRecipes() async {
    final recipes = await _recipeService.getRandomRecipes(3);

    if (mounted) {
      setState(() {
        _randomRecipes = recipes;
      });
    }
  }

  @override
  void dispose() {
    alarm.removeListener(_refreshIngredients);
    super.dispose();
  }

  // [데이터 새로고침 함수]
  // 서비스로부터 유통기한 임박 재료 목록을 비동기(async)로 불러와 화면을 갱신합니다.
  Future<void> _refreshIngredients() async {
    // mounted: 위젯이 화면에 실제로 붙어있는지 확인합니다. (오류 방지)
    if (!mounted) return;

    // setState를 호출하여 _isLoading을 true로 변경 -> 화면에 로딩 스피너 표시
    setState(() => _isLoading = true);

    // 서비스로부터 모든 재료를 가져온 후, 유통기한 순으로 정렬합니다.
    var all = await _service.getAllIngredients();
    var sorted = _service.sortList(all, SortMode.expiryAsc);

    // 위젯이 아직 화면에 있다면, 상태를 업데이트합니다.
    if (mounted) {
      setState(() {
        // 정렬된 목록에서 상위 5개만 가져와 화면에 표시될 리스트를 업데이트합니다.
        _expiringSoonIngredients = sorted.take(5).toList();
        _isLoading = false; // 로딩 완료 -> 로딩 스피너 숨김
      });
    }
  }

  // [헬퍼 메서드: UI 생성]
  // PageView 아래에 현재 페이지를 나타내는 점(인디케이터)들을 그리는 함수입니다.
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 점들을 가운데 정렬
      // List.generate: _recommendedRecipes의 개수만큼 반복하여 위젯 리스트를 생성합니다.
      // [수정] _randomRecipes의 길이를 사용하도록 변경
      children: List.generate(_randomRecipes.length, (index) {
        // GestureDetector: 자식 위젯(Container)에 탭 이벤트를 감지할 수 있게 합니다.
        return GestureDetector(
          onTap: () {
            // 점을 탭하면, PageView를 해당 페이지(index)로 애니메이션과 함께 이동시킵니다.
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 350), // 애니메이션 지속 시간
              curve: Curves.easeIn, // 애니메이션 효과
            );
          },
          child: Container(
            width: 8.0,
            height: 8.0,
            margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0), // 점들 사이의 여백
            decoration: BoxDecoration(
              shape: BoxShape.circle, // 원 모양
              // 현재 페이지(index)와 _currentPage 상태가 같으면 메인 색상, 아니면 회색으로 표시
              color: _currentPage == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  // setState()가 호출될 때마다 이 build 메서드가 다시 실행되어 화면이 업데이트됩니다.
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // SingleChildScrollView: 자식 위젯의 내용이 화면보다 길어질 경우 스크롤이 가능하게 합니다.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // --- 오늘의 레시피 (PageView) ---
          const Text("오늘의 레시피", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // SizedBox로 PageView의 높이를 고정해야 오류가 발생하지 않습니다.
          // [수정] 데이터 로딩 전 빈 화면 방지
          _randomRecipes.isEmpty
              ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
              : SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController, // 위에서 만든 페이지 컨트롤러 연결
              // [수정] 고정 리스트 대신 랜덤 레시피 리스트 사용
              itemCount: _randomRecipes.length, // 페이지의 총 개수
              // onPageChanged: 사용자가 페이지를 스와이프할 때마다 호출됩니다.
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page; // 현재 페이지 상태를 업데이트 -> 인디케이터 색상 변경
                });
              },
              // itemBuilder: 각 페이지의 UI를 동적으로 생성합니다.
              itemBuilder: (context, index) {
                final recipe = _randomRecipes[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0), // 페이지 좌우 여백
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
                          // 이미지가 있으면 표시, 없으면 기본 아이콘 표시
                          // 로컬 이미지(Asset) 대신 네트워크 이미지(Network) 사용
                          Expanded(
                            child: recipe.imageName.isNotEmpty
                                ? Image.network(
                              recipe.imageName,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.rice_bowl, size: 100, color: Colors.grey);
                              },
                            )
                                : const Icon(Icons.rice_bowl, size: 100, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          // Map 키 접근(['name']) 대신 객체 속성(.name) 사용
                          Text(recipe.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // 페이지 인디케이터 위젯을 추가합니다.
          if (_randomRecipes.isNotEmpty) _buildPageIndicator(),
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
                  // [조건부 렌더링]
                  // 로딩 중이면 스피너를, 목록이 비었으면 안내 문구를, 목록이 있으면 리스트를 표시합니다.
                  if (_isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                  else if (_expiringSoonIngredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("임박한 재료가 없습니다!")),
                    )
                  else
                    Column(
                      // _expiringSoonIngredients 리스트의 각 아이템을 IngredientItem 위젯으로 변환합니다.
                      children: _expiringSoonIngredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          // 재사용 가능한 IngredientItem 위젯을 호출합니다.
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