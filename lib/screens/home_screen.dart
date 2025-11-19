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

  @override
  void initState() {
    super.initState();
    _refreshIngredients();
  }

  void _refreshIngredients() {
    var all = _service.getAllIngredients();
    var sorted = _service.sortList(all, SortMode.expiryAsc);
    _expiringSoonIngredients = sorted.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    _refreshIngredients();

    // [수정] 테마 색상 가져오기
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 오늘의 레시피 카드
          Card(
            // [수정] 테마의 primary 색상을 옅게 사용하여 일관성 유지
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colorScheme.primary.withOpacity(0.3), width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Text("오늘의 레시피", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Icon(Icons.image, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text("레시피 이름", style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 유통기한 임박 목록 카드
          Card(
            // primaryContainer는 보통 메인 색상의 아주 연한 버전을 의미합니다.
            color: colorScheme.primaryContainer.withOpacity(0.4),
            elevation: 0, // 플랫한 느낌을 위해 그림자 제거 (선택사항)
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
                          color: colorScheme.onSurface, // 텍스트 색상도 테마 따름
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),


                  if (_expiringSoonIngredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text("임박한 재료가 없습니다!")),
                    )
                  else
                    Column(
                      children: _expiringSoonIngredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0), // 아이템 간 간격
                          child: IngredientItem(
                            ingredient: ingredient,
                            // onEdit null -> 수정 버튼 숨김
                          ),
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