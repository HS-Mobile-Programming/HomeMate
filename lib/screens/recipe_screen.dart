// 레시피 검색·정렬 목록 화면
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  // 레시피 서비스
  final RecipeService _recipeService = RecipeService();
  // 검색·정렬 결과 목록
  List<Recipe> _foundRecipes = [];
  // 정렬 모드 상태
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  // 검색어 상태
  String _searchKeyword = "";
  // 로딩 상태
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  // 검색·정렬 결과 새로고침
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

  // 검색어 변경 시 갱신
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

  // 정렬 모드 전환 후 갱신
  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
    });
    _refreshList();
  }

  // 정렬 버튼 UI
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

  // 검색 결과 없음 안내 포인트
  Widget _buildSuggestionPoint(String text) {
    return Row(
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
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
                            ).then((_) => _refreshList());
                          },
                          child: RecipeCard(recipe: _foundRecipes[index]),
                        );
                      },
                    )
                  : Center(
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F9F9),
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(height: 8),
                            _buildSuggestionPoint("단어의 수를 줄이거나 표준어인지 확인 바랍니다."),
                            const SizedBox(height: 8),
                            _buildSuggestionPoint("보다 일반적인 단어로 검색 바랍니다."),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}