import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

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

  @override
  void initState() {
    _foundRecipes = _allRecipes;
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
    });
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
            const SizedBox(height: 16),

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
                  : const SizedBox( // 결과 없을 때 여백
                height: 200,
                child: Center(child: Text("검색 결과가 없습니다.")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}