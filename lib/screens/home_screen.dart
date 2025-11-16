import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyIngredients = [
      Ingredient(id: 'h1', name: "재료 A", expiryTime: "18:00"),
      Ingredient(id: 'h2', name: "재료 B", expiryTime: "19:30"),
      Ingredient(id: 'h3', name: "재료 C", expiryTime: "20:00"),
      Ingredient(id: 'h4', name: "재료 D", expiryTime: "21:15"),
      Ingredient(id: 'h5', name: "재료 E", expiryTime: "22:00"),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 오늘의 레시피 카드
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFB2DFDB), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    "오늘의 레시피",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.image, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "레시피 이름",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 유통기한 임박 목록 카드
          Card(
            color: const Color(0xFFE0F2F1),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MM월 DD일",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dummyIngredients.length,
                    itemBuilder: (context, index) {
                      return IngredientItem(
                        ingredient: dummyIngredients[index],
                      );
                    },
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
