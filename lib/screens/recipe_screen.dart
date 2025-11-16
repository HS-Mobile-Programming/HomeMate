import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../services/recipe_service.dart'; // [수정] 1. 서비스 import

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // [추가] 2. 서비스 객체 생성
  final RecipeService _service = RecipeService();

  // [유지] 3. UI 상태 변수
  List<Recipe> _foundRecipes = [];
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;
  String _searchKeyword = ""; // 검색어 상태

  // [제거] 4. 로직 및 데이터 삭제
  // final List<Recipe> _allRecipes = [...] (삭제)
  // _runFilter() (삭제)
  // _sortList() (삭제)

  @override
  void initState() {
    super.initState();
    _refreshList(); // [추가] 5. 초기 로드
  }

  // [추가] 6. UI 갱신을 위한 중앙 함수
  void _refreshList() {
    setState(() {
      // 서비스에서 데이터를 가져오고
      var recipes = _service.getRecipes(keyword: _searchKeyword);
      // 서비스에서 데이터를 정렬함
      _foundRecipes = _service.sortRecipes(recipes, _sortMode);
    });
  }

  // [추가] 7. UI 이벤트 핸들러 (로직 X, 오직 호출)
  void _onSearchChanged(String keyword) {
    _searchKeyword = keyword;
    _refreshList();
  }

  void _onSortPressed() {
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
    });
    _refreshList(); // 정렬 모드 변경 후 갱신
  }

  // (정렬 버튼 UI는 기존과 동일)
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert;
    String label;
    switch (_sortMode) {
      case RecipeSortMode.nameAsc: label = "이름 (가-힣)"; break;
      case RecipeSortMode.nameDesc: label = "이름 (힣-가)"; break;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
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
            TextField(
              onChanged: _onSearchChanged, // [수정] 8. 이벤트 핸들러 연결
              decoration: InputDecoration(
                labelText: '검색할 재료',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onSortPressed, // [수정] 9. 이벤트 핸들러 연결
                    child: _buildSortButtonChild(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _foundRecipes.isNotEmpty
                  ? ListView.builder(
                itemCount: _foundRecipes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipe: _foundRecipes[index]),
                        ),
                      )
                      // [수정] 10. 돌아왔을 때 갱신 (즐겨찾기 상태 반영)
                          .then((_) => _refreshList());
                    },
                    child: RecipeCard(recipe: _foundRecipes[index]),
                  );
                },
              )
                  : const Center(child: Text("검색 결과가 없습니다.")),
            ),
          ],
        ),
      ),
    );
  }
}