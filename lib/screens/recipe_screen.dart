import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../data/recipe_data.dart'; // [추가] 공용 데이터 import

enum RecipeSortMode { nameAsc, nameDesc }

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // [제거] final List<Recipe> _allRecipes = [...] (기존 데이터 삭제)

  List<Recipe> _foundRecipes = [];
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;

  @override
  void initState() {
    _foundRecipes = allRecipes; // [수정] 공용 데이터로 초기화
    _sortList();
    super.initState();
  }

  void _runFilter(String keyword) {
    List<Recipe> results = [];
    if (keyword.isEmpty) {
      results = allRecipes; // [수정] 공용 데이터
    } else {
      results = allRecipes.where((recipe) => recipe.title.contains(keyword)).toList();
    }
    setState(() {
      _foundRecipes = results;
      _sortList();
    });
  }

  void _sortList() {
    setState(() {
      switch (_sortMode) {
        case RecipeSortMode.nameAsc:
          _foundRecipes.sort((a, b) => a.title.compareTo(b.title));
          break;
        case RecipeSortMode.nameDesc:
          _foundRecipes.sort((a, b) => b.title.compareTo(a.title));
          break;
      }
    });
  }

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
                      // [추가] 상세 화면에서 돌아왔을 때 화면 갱신
                          .then((_) => setState(() { _runFilter(""); }));
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