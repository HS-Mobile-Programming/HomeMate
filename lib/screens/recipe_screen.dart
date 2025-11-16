import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

// [추가] 1. 정렬 모드 enum
enum RecipeSortMode { nameAsc, nameDesc }

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final List<Recipe> _allRecipes = [
    Recipe(
        title: "김치찌개", description: "매콤하고 맛있는 김치찌개", imageUrl: "",
        difficulty: "쉬움", ingredients: ["김치 1포기", "돼지고기 200g", "두부 1모"], steps: ["김치를 볶는다.", "물을 붓고 끓인다.", "고기와 두부를 넣는다."]),
    Recipe(title: "된장찌개", description: "구수한 된장찌개", imageUrl: "", difficulty: "보통"),
    Recipe(title: "파스타", description: "토마토 파스타", imageUrl: "", difficulty: "쉬움"),
  ];

  List<Recipe> _foundRecipes = [];
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc; // [수정] 정렬 상태 변수

  @override
  void initState() {
    _foundRecipes = _allRecipes;
    _sortList();
    super.initState();
  }

  void _runFilter(String keyword) {
    List<Recipe> results = [];
    if (keyword.isEmpty) {
      results = _allRecipes;
    } else {
      results = _allRecipes.where((recipe) => recipe.title.contains(keyword)).toList();
    }
    setState(() {
      _foundRecipes = results;
      _sortList();
    });
  }

  // [수정] 2. 정렬 로직
  void _sortList() {
    setState(() {
      switch (_sortMode) {
        case RecipeSortMode.nameAsc:
          _foundRecipes.sort((a, b) => a.title.compareTo(b.title)); // 가-힣 순
          break;
        case RecipeSortMode.nameDesc:
          _foundRecipes.sort((a, b) => b.title.compareTo(a.title)); // 힣-가 순
          break;
      }
    });
  }

  // [추가] 3. 정렬 버튼 텍스트/아이콘 반환
  Widget _buildSortButtonChild() {
    IconData icon = Icons.swap_vert;
    String label;

    switch (_sortMode) {
      case RecipeSortMode.nameAsc:
        label = "이름 (가-힣)";
        break;
      case RecipeSortMode.nameDesc:
        label = "이름 (힣-가)";
        break;
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
            // 1. 검색창
            TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                labelText: '검색할 재료',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            // [수정] 4. 정렬 버튼 영역
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sortMode = _sortMode == RecipeSortMode.nameAsc
                            ? RecipeSortMode.nameDesc
                            : RecipeSortMode.nameAsc;
                        _sortList();
                      });
                    },
                    child: _buildSortButtonChild(), // 버튼 내용 변경
                  ),
                ],
              ),
            ),

            // 2. 레시피 리스트
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
                      );
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