import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart'; // 1. 진짜 재료 서비스 import

// [수정] 2. StatelessWidget -> StatefulWidget (탭 이동 시 갱신을 위해)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 3. 서비스 객체 생성
  final RefrigeratorService _service = RefrigeratorService();
  List<Ingredient> _expiringSoonIngredients = [];

  @override
  void initState() {
    super.initState();
    _refreshIngredients();
  }

  // 4. 홈 화면이 보일 때마다 재료 목록 갱신
  // (탭을 바꿀 때마다 build가 다시 실행되므로 build에서 호출)
  void _refreshIngredients() {
    // (나중에 여기를 '유통기한 임박순'으로 정렬하는 로직으로 고도화)
    _expiringSoonIngredients = _service.getAllIngredients();

    // (예시: 유통기한순 정렬 및 5개만 자르기)
    _expiringSoonIngredients = _service.sortList(_expiringSoonIngredients, SortMode.expiryAsc);
    _expiringSoonIngredients = _expiringSoonIngredients.take(5).toList();
  }


  @override
  Widget build(BuildContext context) {
    // [수정] 5. build 시점에 목록 갱신 (탭 이동시 반영)
    _refreshIngredients();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 오늘의 레시피 카드 (기존과 동일)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFB2DFDB), width: 2),
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
            color: const Color(0xFFE0F2F1),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "유통기한 임박 재료", // [수정] 6. 제목 변경
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // [수정] 7. '가짜' 데이터 대신 '진짜' 데이터 사용
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _expiringSoonIngredients.length,
                    itemBuilder: (context, index) {
                      return IngredientItem(
                        ingredient: _expiringSoonIngredients[index],
                        // onEdit을 전달 안 함 (수정 버튼 숨김)
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