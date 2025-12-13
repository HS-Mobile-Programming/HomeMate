// 레시피 검색 및 정렬 목록 화면
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/recommendation_service.dart';
import '../models/recipe.dart';
import '../models/recipe_sort_mode.dart';
import '../services/recipe_service.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final RecipeService _recipeService = RecipeService();
  final RecommendationService _recommendationService = RecommendationService();

  // 검색 및 정렬 결과 목록
  List<Recipe> _foundRecipes = [];
  // 정렬 모드 상태
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  // 검색어 상태
  String _searchKeyword = "";
  // 로딩 상태
  bool _isLoading = false;
  // AI 로딩 상태
  bool _isAiLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // 검색 및 정렬 결과를 새로고침합니다
  Future<void> _refreshList() async {
    setState(() => _isLoading = true);
    final recipes = await _recipeService.getRecipes(keyword: _searchKeyword);
    final sortedRecipes = _recipeService.sortRecipes(recipes, _sortMode);

    if (mounted) {
      setState(() {
        _foundRecipes = sortedRecipes;
        _isLoading = false;
      });
    }
  }

  // AI 검색을 수행합니다
  Future<void> _onAiSearchPressed() async {
    if (_searchKeyword.isEmpty) return;

    setState(() {
      _isAiLoading = true;
    });

    try {
      final aiRecipes = await _recommendationService.getAiRecipesFromKeyword(_searchKeyword);

      if (mounted) {
        if (aiRecipes.isNotEmpty) {
          setState(() {
            _foundRecipes = aiRecipes;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("AI가 새로운 레시피를 만들었습니다!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("AI가 레시피를 생성하지 못했습니다.")),
          );
        }
      }
    }
    catch (e) {
      if (mounted) {
        final errorMessage = e.toString();
        if (errorMessage.contains('quota') || 
            errorMessage.contains('exceeded') ||
            errorMessage.contains('rate-limit')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("일일 AI 사용 한도를 초과했습니다. 내일 다시 시도해주세요."),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("오류가 발생했습니다: ${e.toString()}"),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
    finally {
      if (mounted) {
        setState(() {
          _isAiLoading = false;
        });
      }
    }
  }

  // 검색어가 변경될 때 호출됩니다
  void _onSearchChanged(String keyword) {
    if (RegExp(r'[^가-힣ㄱ-ㅎㅏ-ㅣ\s]').hasMatch(keyword)) {
      Fluttertoast.showToast(
        msg: "잘못된 입력입니다. 검색어에 영어나 숫자, 특수문자 등이 들어가지 않았는지 확인 바랍니다.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    _searchKeyword = keyword;
    _refreshList();
  }

  // 정렬 모드를 전환하고 목록을 갱신합니다
  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
    });
    final sorted = _recipeService.sortRecipes(_foundRecipes, _sortMode);
    setState(() {
      _foundRecipes = sorted;
    });
  }

  // 정렬 버튼의 UI를 구성합니다
  Widget _buildSortButtonChild() {
    final icon = Icons.swap_vert;
    final label = _sortMode == RecipeSortMode.nameAsc ? "이름 (가-힣)" : "이름 (힣-가)";
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _buildSuggestionPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(" • ", style: TextStyle(color: Colors.black54, height: 1.5)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 검색창
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: '검색할 재료',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            // 정렬 버튼
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onSortPressed,
                    child: _buildSortButtonChild(),
                  ),
                ],
              ),
            ),
            // 목록/로딩/빈 상태
            Expanded(
              child: _isLoading || _isAiLoading
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (_isAiLoading) ...[
                    const SizedBox(height: 16),
                    const Text("AI가 레시피를 생성 중입니다..."),
                  ]
                ],
              )
                  : _foundRecipes.isNotEmpty
                  ? ListView.builder(
                itemCount: _foundRecipes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(
                            recipe: _foundRecipes[index],
                          ),
                        ),
                      );
                    },
                    child: RecipeCard(recipe: _foundRecipes[index]),
                  );
                },
              ) : SingleChildScrollView(
                child: Column(
                  children: [
                    // 검색 결과 없음 안내
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.info_outline, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                "검색 결과가 없습니다.",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSuggestionPoint("단어의 철자가 정확한지 다시 확인 바랍니다."),
                          _buildSuggestionPoint("보다 일반적인 단어로 검색 바랍니다."),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // AI 검색 제안
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        border: Border.all(color: Colors.deepPurple.shade100),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 28),
                              const SizedBox(width: 8),
                              const Text(
                                "AI 레시피 추천",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "찾으시는 레시피가 없다면,\n'$_searchKeyword' 재료로 AI에게 새로운 레시피를 물어보세요.",
                            style: TextStyle(
                              color: Colors.deepPurple.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _searchKeyword.isNotEmpty
                                  ? _onAiSearchPressed
                                  : null,
                              icon: const Icon(Icons.search, color: Colors.white),
                              label: const Text(
                                "AI 검색 시작하기",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
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