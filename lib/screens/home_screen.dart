// [SCREEN CLASS] - StatefulWidget
// '홈' 탭 (index 0)에 표시되는 화면입니다.
// '오늘의 레시피' 카드와 '유통기한 임박 재료' 목록을 보여줍니다.
//
// 'StatefulWidget':
// 이 화면은 '유통기한 임박 재료(_expiringSoonIngredients)' 목록을
// '서비스(_service)'로부터 '불러와서' 그 '상태'를 '스스로' 관리해야 하므로
// StatefulWidget으로 선언되었습니다.
// 로직을 위해 StatefulWidget으로 구현되었습니다.)

import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../widgets/ingredient_item.dart';
import '../services/refrigerator_service.dart'; // 1. 진짜 재료 서비스 import

//  2. 홈 화면 StatefulWidget
class HomeScreen extends StatefulWidget {
  // const HomeScreen(...): 위젯 생성자
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [상태 변수 (State Variables)]

  // 3. 서비스 객체 생성
  // '냉장고' 로직(데이터)을 담당하는 서비스 객체를 생성합니다.
  final RefrigeratorService _service = RefrigeratorService();

  // 3. UI 상태 변수
  // 화면에 표시될 '유통기한 임박 재료' 목록을 담을 리스트입니다.
  List<Ingredient> _expiringSoonIngredients = [];

  // [initState]
  // 이 위젯(화면)이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 재료 목록을 한 번 불러옵니다.
    _refreshIngredients();
  }

  // [갱신 함수]
  // 4. 홈 화면이 보일 때마다 재료 목록 갱신
  void _refreshIngredients() {
    // (서비스에서 '모든' 재료를 가져옵니다.)
    var allIngredients = _service.getAllIngredients();

    // (예시: 유통기한순 정렬 및 5개만 자르기)
    // 1. 서비스의 'sortList' 로직을 호출하여 '유통기한 임박순(expiryAsc)'으로 정렬
    var sortedIngredients = _service.sortList(allIngredients, SortMode.expiryAsc);
    // 2. 'take(5)': 정렬된 리스트에서 '앞의 5개' 항목만 가져옵니다.
    // 3. 'toList()': 'take'의 결과(Iterable)를 'List'로 변환합니다.
    _expiringSoonIngredients = sortedIngredients.take(5).toList();
  }


  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  // 'MainScreen'에서 탭이 '전환'될 때마다 이 'build' 메서드가 '다시 실행'됩니다.
  @override
  Widget build(BuildContext context) {
    //  5. build 시점에 목록 갱신 (탭 이동시 반영)
    // 사용자가 '홈' 탭을 누를 때마다(build가 실행될 때마다)
    // '_refreshIngredients' 함수를 호출하여 목록을 '항상 최신'으로 갱신합니다.
    _refreshIngredients();

    // SingleChildScrollView: 화면 내용이 길어질 경우 스크롤 가능
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // 화면 바깥쪽 여백
      child: Column( // 위젯들을 세로(수직)로 배치
        children: [
          // [오늘의 레시피 카드 (기존과 동일)]
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              // side: 카드 테두리 설정
              side: const BorderSide(color: Color(0xFFB2DFDB), width: 2), // 연한 청록색 테두리
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0), // 카드 내부 여백
              child: Column(
                children: [
                  const Text("오늘의 레시피", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Icon(Icons.image, size: 100, color: Colors.grey), // 임시 이미지
                  const SizedBox(height: 16),
                  const Text("레시피 이름", style: TextStyle(fontSize: 18)), // 임시 텍스트
                ],
              ),
            ),
          ),
          const SizedBox(height: 24), // 두 카드 사이의 수직 간격

          // [유통기한 임박 목록 카드]
          Card(
            color: const Color(0xFFE0F2F1), // 카드 배경색 (연한 청록색)
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // '제목'을 왼쪽 정렬
                children: [
                  const Text(
                    "유통기한 임박 재료",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // (build 시점에 갱신된) '_expiringSoonIngredients' 리스트를 사용
                  ListView.builder(
                    shrinkWrap: true, // (SingleChildScrollView 안의 ListView - 필수)
                    physics: const NeverScrollableScrollPhysics(), // (ListView 스크롤 비활성화 - 필수)
                    itemCount: _expiringSoonIngredients.length, // 리스트의 개수만큼
                    itemBuilder: (context, index) {
                      // 'IngredientItem' 위젯을 재사용합니다.
                      return IngredientItem(
                        ingredient: _expiringSoonIngredients[index],
                        // 'onEdit' 파라미터를 '전달하지 않습니다' (null).
                        // -> 'IngredientItem' 위젯은 '수정' 버튼을 그리지 않습니다.
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