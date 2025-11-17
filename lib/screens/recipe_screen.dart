// [SCREEN CLASS] - StatefulWidget
// '레시피' 탭 (index 2)에 표시되는 화면입니다.
// '검색' 기능과 '정렬' 기능을 통해 레시피 목록을 보여줍니다.
//
// 'StatefulWidget':
// '검색어(_searchKeyword)', '정렬 모드(_sortMode)', '검색 결과(_foundRecipes)' 등
// 사용자의 입력에 따라 '변경되는 상태'들을 '스스로' 관리해야 하므로
// StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import '../services/recipe_service.dart';

class RecipeScreen extends StatefulWidget {
  // const RecipeScreen(...): 위젯 생성자
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  // [상태 변수 (State Variables)]

  //  2. 서비스 객체 생성
  // '레시피' 로직을 담당하는 서비스 객체를 생성합니다.
  final RecipeService _service = RecipeService();

  //  3. UI 상태 변수

  // '화면에 보여질' (검색 및 정렬이 완료된) 레시피 목록입니다.
  List<Recipe> _foundRecipes = [];

  // '현재 정렬 방식'을 저장합니다. (기본값: 이름 오름차순)
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;

  // '현재 검색어' (TextField에 입력된 값)를 저장합니다. (기본값: 빈 문자열)
  String _searchKeyword = "";

  // [initState]
  // 이 위젯(화면)이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 '전체' 레시피 목록을 한 번 불러옵니다.
    _refreshList(); //  5. 초기 로드
  }

  // 6. UI 갱신을 위한 중앙 함수
  // 이 함수는 화면에 보여질 '_foundRecipes' 목록을 갱신하는 유일한 통로입니다.
  // (1) 처음 로드 시, (2) 검색어 변경 시, (3) 정렬 변경 시, (4) 상세 화면에서 돌아올 시 호출됩니다.
  void _refreshList() {
    // 'setState()': 화면을 다시 그리도록 요청합니다.
    setState(() {
      // (A) 서비스에서 '데이터를 가져옵니다' (검색)
      // 현재 '_searchKeyword' (상태 변수) 값을 서비스에 전달하여 '검색'을 요청합니다.
      // (키워드가 비어있으면 서비스가 '전체' 목록을 반환할 것입니다.)
      var recipes = _service.getRecipes(keyword: _searchKeyword);

      // (B) 서비스에서 '데이터를 정렬합니다'
      // (A)에서 검색된 'recipes' 목록과
      // 현재 '_sortMode' (상태 변수) 값을 서비스에 전달하여 '정렬'을 요청합니다.
      _foundRecipes = _service.sortRecipes(recipes, _sortMode);
    });
  }

  //  7. UI 이벤트 핸들러 (로직 X, 오직 호출)

  // 'TextField'의 'onChanged' 콜백에 연결됩니다. (텍스트가 '바뀔 때마다' 호출됨)
  void _onSearchChanged(String keyword) {
    // 1. 입력받은 'keyword'를 '_searchKeyword' (상태 변수)에 '저장'합니다.
    _searchKeyword = keyword;
    // 2. '중앙 갱신 함수(_refreshList)'를 '호출'합니다.
    _refreshList();
    // -> _refreshList는 변경된 _searchKeyword를 사용하여 서비스에 검색을 요청합니다.
  }

  // '정렬' 버튼의 'onPressed' 콜백에 연결됩니다.
  void _onSortPressed() {
    // 'setState()': 정렬 모드(_sortMode)가 '변경'되었음을 알립니다.
    setState(() {
      // 1. 현재 '_sortMode' (상태 변수)를 '변경'합니다.
      // (이름 오름차순 -> 이름 내림차순, 이름 내림차순 -> 이름 오름차순)
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
    });
    // 2. '중앙 갱신 함수(_refreshList)'를 '호출'합니다.
    _refreshList(); // 정렬 모드 변경 후 갱신
    // -> _refreshList는 변경된 _sortMode를 사용하여 서비스에 정렬을 요청합니다.
  }

  // (정렬 버튼 UI는 기존과 동일 - 'refrigerator_screen'의 헬퍼 함수와 유사)
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

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold( // (배경색 등을 위해 Scaffold로 감싸는 것이 일반적)
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 바깥쪽 여백
        child: Column( // 위젯들을 세로(수직)로 배치
          children: [
            // [검색창]
            TextField(
              // onChanged: 텍스트가 '입력될 때마다' 호출됩니다.
              onChanged: _onSearchChanged, //  8. 이벤트 핸들러 연결
              decoration: InputDecoration(
                labelText: '검색할 재료', // (실제로는 '레시피 이름' 검색)
                suffixIcon: const Icon(Icons.search), // 오른쪽 끝에 '검색' 아이콘
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), // 둥근 테두리
                filled: true,
                fillColor: Colors.white, // 흰색 배경
              ),
            ),

            // [정렬 버튼 영역]
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row( // Row를 사용하여 버튼을 '오른쪽 끝'으로 정렬
                mainAxisAlignment: MainAxisAlignment.end, // '가로' 정렬: '끝(오른쪽)'
                children: [
                  TextButton(
                    onPressed: _onSortPressed, //  9. 이벤트 핸들러 연결
                    child: _buildSortButtonChild(), // 헬퍼 함수가 생성한 UI
                  ),
                ],
              ),
            ),

            // [레시피 목록 영역]
            // Expanded: 'Column' 안에서 '남은 모든 세로 공간'을 차지합니다.
            // (검색창, 정렬 버튼을 제외한 모든 하단 영역)
            Expanded(
              // '_foundRecipes' (상태 변수)가 '비어있지 않으면' (true) -> ListView
              // '비어있으면' (false) -> Center(Text)
              child: _foundRecipes.isNotEmpty
                  ? ListView.builder( // 목록이 있으면
                itemCount: _foundRecipes.length, // 목록의 개수만큼
                itemBuilder: (context, index) {
                  // GestureDetector: 자식(RecipeCard)에 '탭(클릭)' 이벤트를 주기 위해 사용
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(...): '상세' 화면으로 '이동'
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // '상세' 화면(RecipeDetailScreen)을 생성할 때,
                          // 'recipe' 파라미터로 '현재 탭한 레시피(_foundRecipes[index])'를
                          // '전달'합니다.
                          builder: (context) => RecipeDetailScreen(recipe: _foundRecipes[index]),
                        ),
                      )
                      //  10. 돌아왔을 때 갱신 (즐겨찾기 상태 반영)
                          .then((_) => _refreshList());
                    },
                    // 'RecipeCard' 위젯을 재사용합니다.
                    child: RecipeCard(recipe: _foundRecipes[index]),
                  );
                },
              )
                  : const Center(child: Text("검색 결과가 없습니다.")), // 목록이 없으면
            ),
          ],
        ),
      ),
    );
  }
}