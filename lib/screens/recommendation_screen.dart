// [SCREEN CLASS] - StatefulWidget
// '추천' 탭 (index 3)에 표시되는 화면입니다.
// '선호도 설정' 버튼과 '정렬' 기능을 통해 '추천된' 레시피 목록을 보여줍니다.
//
// 'StatefulWidget':
// '정렬 모드(_sortMode)'와 '추천 결과(_recommendedRecipes)' 상태를
// '스스로' 관리해야 하므로 StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';
import 'tags_screen.dart';
import '../services/recommendation_service.dart';
import '../services/recipe_service.dart'; // (정렬 enum 재사용)

class RecommendationScreen extends StatefulWidget {
  // const RecommendationScreen(...): 위젯 생성자
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>
    with AutomaticKeepAliveClientMixin {
  // [상태 변수 (State Variables)]

  //  2. 서비스 객체
  // '추천' 로직을 담당하는 서비스 객체를 생성합니다.
  final RecommendationService _service = RecommendationService();

  // 3. UI 상태 변수

  // 화면에 표시될 '추천 레시피' 목록입니다.
  List<Recipe> _recommendedRecipes = [];

  // 현재 정렬 방식입니다. (기본값: 이름 오름차순)
  RecipeSortMode _sortMode = RecipeSortMode.nameAsc;

  // 로딩 상태 변수
  bool _isLoading = false;

  // 4. 태그 저장소
  // 사용자가 'TagsScreen'에서 선택한 태그 목록을 기억하는 변수입니다.
  // 이 변수가 있어야 TagsScreen에 들어갈 때 "이거 원래 체크되어 있었어"라고 알려줄 수 있습니다.
  List<String> _savedTags = [];

  // [추가] 초기 로드 여부를 추적하는 변수
  bool _hasInitialLoad = false;

  // AutomaticKeepAliveClientMixin 설정
  @override
  bool get wantKeepAlive => true;

  // [initState]
  // 화면이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      _refreshList();
    }
  }

  // 6. 중앙 갱신 함수
  // (RecipeScreen의 _refreshList와 동일한 구조)
  Future<void> _refreshList({bool clearCache = false}) async {
    setState(() => _isLoading = true); // 로딩 시작

    try {
      if (clearCache) {
        _service.clearCache();
      }
      // [수정] 선택된 태그를 서비스에 전달
      var recipes = await _service.getRecommendations(
        selectedTags: _savedTags.isEmpty ? null : _savedTags,
      );
      var sortedRecipes = _service.sortRecipes(recipes, _sortMode);

      if (mounted) {
        setState(() {
          _recommendedRecipes = sortedRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("추천을 불러오는데 실패했습니다.")),
        );
      }
    }
  }

  //  7. 이벤트 핸들러

  // '정렬' 버튼의 'onPressed' 콜백에 연결됩니다.
  void _onSortPressed() {
    // 정렬 모드만 변경하고, 이미 받은 데이터를 정렬만 함 (새 추천 받지 않음)
    setState(() {
      _sortMode = _sortMode == RecipeSortMode.nameAsc
          ? RecipeSortMode.nameDesc
          : RecipeSortMode.nameAsc;
      // 이미 받은 데이터를 정렬만 함
      _recommendedRecipes = _service.sortRecipes(_recommendedRecipes, _sortMode);
    });
  }

  // '선호도 설정' 버튼의 'onPressed' 콜백에 연결됩니다.
  // TagsScreen을 열 때 저장된 태그를 보내고, 돌아올 때 결과를 받아옵니다.
  void _onPreferencesPressed() async {
    // 1. 화면을 열 때 '주머니에 있던 태그(_savedTags)'를 쥐여서 보냅니다.
    // (push가 Future를 반환하므로 await를 사용해 결과를 기다립니다)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagsScreen(
          initialSelectedTags: _savedTags, // "이거 원래 체크되어 있었어" 전달
        ),
      ),
    );

    // 2. 'TagsScreen'에서 '뒤로가기'로 '돌아왔을 때'
    // 결과물(result)이 있으면 내 주머니(_savedTags)를 갱신합니다.
    if (result != null) {
      setState(() {
        _savedTags = result; // 받아온 태그 목록 저장
      });

      // 확인용 로그
      print("갱신된 태그 목록: $_savedTags");

      // [수정] 저장 후 자동 추천 제거 - 추천 버튼을 눌러야만 재추천됨
      // _refreshList() 제거됨
    }
  }

  // (정렬 버튼 UI 헬퍼 함수 - RecipeScreen과 동일)
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
    super.build(context);
    return Scaffold( // (배경색 등을 위해 Scaffold로 감싸기)
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 바깥쪽 여백
        child: Column( // 위젯들을 세로(수직)로 배치
          children: [
            // [상단 버튼 영역]
            Row( // 위젯들을 가로(수평)로 배치
              // mainAxisAlignment: 가로 정렬 방식
              // 'spaceBetween': 자식 위젯들 사이의 '공간(Space)'을 '균등하게(Between)' 배분
              // (왼쪽 버튼 그룹은 '왼쪽 끝'에, 오른쪽 정렬 버튼은 '오른쪽 끝'에 붙게 됨)
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // [왼쪽 버튼 그룹]
                Row(
                  children: [
                    // '_buildTopButton' 헬퍼 메서드를 사용하여 버튼 생성
                    _buildTopButton(
                      text: "선호도 설정",
                      onPressed: _onPreferencesPressed, //  8. 핸들러 연결
                    ),
                    const SizedBox(width: 8), // 버튼 사이 간격
                    // '추천' 버튼 (누르면 '_refreshList'를 호출하여 새 추천 받기)
                    _buildTopButton(
                      text: "추천",
                      onPressed: () => _refreshList(clearCache: true),
                    ),
                  ],
                ),
                // [오른쪽 정 렬 버튼]
                TextButton(
                  onPressed: _onSortPressed, //  9. 핸들러 연결
                  child: _buildSortButtonChild(),
                ),
              ],
            ),
            const SizedBox(height: 16), // 상단 버튼과 목록 사이 간격

            // [추천 목록 영역]
            // Expanded: 'Column' 안에서 '남은 모든 세로 공간'을 차지
            Expanded(
              // 로딩 중이면 스피너 표시
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recommendedRecipes.isEmpty
                  ? const Center(child: Text("선호도에 맞는 추천 레시피가 없습니다."))
                  : ListView.builder(
                itemCount: _recommendedRecipes.length,
                itemBuilder: (context, index) {
                  // GestureDetector: '탭' 이벤트 처리
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // 'recipe' 파라미터로 '탭한 추천 레시피' 전달
                          builder: (context) => RecipeDetailScreen(
                              recipe: _recommendedRecipes[index]
                          ),
                        ),
                      )
                      // [수정] 돌아왔을 때 UI만 갱신 (즐겨찾기 상태 반영, 새 추천 받지 않음)
                          .then((_) {
                            if (mounted) {
                              setState(() {
                                // UI만 갱신하여 즐겨찾기 상태 반영
                              });
                            }
                          });
                    },

                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12), // 카드 하단 여백
                      decoration: BoxDecoration(
                        color: Colors.green.shade50, // 연한 하늘색 배경
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // 'RecipeCard' 위젯을 재사용합니다.
                      child: RecipeCard(recipe: _recommendedRecipes[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 (Helper Method)]
  // '선호도 설정', '추천' 버튼처럼 '반복되는 상단 버튼 UI'를 생성하는 함수입니다.
  Widget _buildTopButton({required String text, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed, // 전달받은 'onPressed' 함수 연결
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade50, // 연보라색 배경
        foregroundColor: Colors.black, // 글자색 검정
        elevation: 0, // 그림자 없음
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}