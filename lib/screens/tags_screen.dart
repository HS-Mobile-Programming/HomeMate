// [SCREEN CLASS] - StatefulWidget
// '선호도 설정 (태그)' 화면입니다.
// '추천' 탭에서 '선호도 설정' 버튼을 누르면 이 화면으로 이동합니다.
//
// 'StatefulWidget':
// '여러 개의 태그(tags)' 목록을 '상태'로 가지고 있어야 하며,
// 사용자가 '태그를 탭'하면 '각 태그의 isSelected 상태'를 '변경'하고
// UI(색상, 테두리)를 '갱신'해야 하므로 StatefulWidget으로 선언되었습니다.

import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../widgets/tag_item.dart';

class TagsScreen extends StatefulWidget {
  // 부모 화면에서 전달받은 '저장된 태그 목록'을 받을 변수입니다.
  final List<String>? initialSelectedTags;

  // const TagsScreen(...): 위젯 생성자
  // 생성자에서 initialSelectedTags를 받을 수 있게 수정했습니다.
  const TagsScreen({
    super.key,
    this.initialSelectedTags
  });

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  // [상태 변수 (State Variable)]

  // 태그를 그룹별로 관리하기 위해 Map으로 변경했습니다.
  // Key: 그룹 이름 (String), Value: 태그 리스트 (List<TagModel>)
  late Map<String, List<TagModel>> tagGroups;

  // [initState]
  // 화면이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    // 'tags' (상태 변수)를 '초기화'합니다.

    // 전달받은 초기 태그 목록이 있다면, 미리 Set으로 변환하여 검색 속도를 높입니다.
    // (없으면 빈 목록 {} 사용)
    // widget.initialSelectedTags는 위에서 선언한 변수를 가져오는 것입니다.
    final savedTags = widget.initialSelectedTags?.toSet() ?? {};

    // 요청하신 태그들을 속성별로 그룹화하여 초기화했습니다.
    // 생성 시 'savedTags'에 포함되어 있다면 isSelected를 true로 설정합니다.
    tagGroups = {
      "맛 & 풍미": [
        "매콤한", "담백한", "짭짤한", "달달한",
        "새콤한", "고소한", "기름진", "깔끔한"
      ].map((name) => TagModel(name, isSelected: savedTags.contains(name))).toList(),

      "주재료": [
        "고기요리", "해산물요리", "채소요리", "면요리", "밥요리"
      ].map((name) => TagModel(name, isSelected: savedTags.contains(name))).toList(),

      "음식 분류": [
        "반찬", "메인요리", "에피타이저", "디저트"
      ].map((name) => TagModel(name, isSelected: savedTags.contains(name))).toList(),
    };
  }

  // '저장하기' 버튼을 눌렀을 때 실행되는 함수입니다.
  // 선택된 태그들을 수집하여 서버로 보내거나 이전 화면으로 전달합니다.
  void _onSave() {
    List<String> selectedTags = [];

    // Map을 순회하며 'isSelected'가 true인 태그만 골라냅니다.
    tagGroups.forEach((category, tags) {
      for (var tag in tags) {
        if (tag.isSelected) {
          selectedTags.add(tag.name);
        }
      }
    });

    // 1. 하단에 안내 바(SnackBar) 표시 (선택 사항)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("취향 태그가 저장되었습니다."),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 2. 이전 화면으로 데이터(selectedTags)를 들고 돌아갑니다.
    Navigator.pop(context, selectedTags);
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    //  "선호도 설정" 화면으로 보이도록 Scaffold 추가
    return Scaffold(
      // AppBar: 화면 상단 바
      appBar: AppBar(
        title: const Text("선호도 설정 (태그)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5), // 앱 공통 배경색

      // body: 화면 본문 영역
      // 그룹별로 섹션을 나누어 표시하기 위해 ListView로 변경했습니다.
      // 하단 FloatingActionButton에 가려지지 않도록 padding bottom을 넉넉히 줍니다.
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),

        // Map의 각 항목(Entry)을 순회하며 UI(Column) 리스트로 변환합니다.
        children: tagGroups.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 제목 왼쪽 정렬
            children: [
              // 그룹 제목 (예: 맛과 특징)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // GridView.builder:
              // '격자(Grid)' 형태의 목록을 '동적'으로(builder) 생성하는 위젯입니다.
              GridView.builder(
                shrinkWrap: true, // [추가] ListView 안에서 자식 높이만큼만 차지하도록 설정 (필수)
                physics: const NeverScrollableScrollPhysics(), // [추가] ListView와 스크롤 충돌 방지 (필수)

                // gridDelegate: '격자(Grid)'를 '어떻게' 나눌지 정의하는 '위임자(Delegate)'
                // 'SliverGridDelegateWithFixedCrossAxisCount':
                //   '가로(CrossAxis)'에 '고정된(Fixed)' '개수(Count)'로 나누는 방식
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 가로(CrossAxis)에 '4개'의 아이템을 배치
                  mainAxisSpacing: 8, // '세로(MainAxis)' 아이템 간의 간격
                  crossAxisSpacing: 8, // '가로(CrossAxis)' 아이템 간의 간격
                ),

                itemCount: entry.value.length, // 해당 그룹의 태그 개수

                itemBuilder: (context, index) {
                  // 'TagItem' 위젯을 재사용합니다.
                  final tag = entry.value[index];
                  return TagItem(
                    tag: tag, // 'index'에 해당하는 'tag' 데이터 전달

                    // onTap: 'TagItem' 위젯이 '탭'되었을 때 실행될 함수 전달
                    onTap: () {
                      // 'setState()': 플러터에게 "상태가 변경되었으니 화면을 다시 그려라"라고 알립니다.
                      setState(() {
                        // 'tags' 리스트의 'index' 번째 아이템의
                        // 'isSelected' 값을 '!' (NOT) 연산자로 '뒤집습니다'.
                        // (true -> false, false -> true)
                        tag.isSelected = !tag.isSelected;

                        // (나중에 여기에 '변경된 태그'를 '서비스'나 'DB'에
                        //  '저장'하는 로직이 추가되어야 합니다.)
                      });
                      // -> 'setState'가 호출되면 'build'가 다시 실행되고,
                      //    'GridView.builder'가 'TagItem'들을 다시 그립니다.
                      // -> 'TagItem'은 변경된 'tags[index].isSelected' 값을 전달받아
                      //    '색상'과 '테두리'를 '갱신'합니다.
                    },
                  );
                },
              ),

              const SizedBox(height: 24), // 그룹 간의 간격 추가
            ],
          );
        }).toList(),
      ),

      // 화면 하단에 고정된 '저장하기' 버튼입니다.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSave, // 버튼 클릭 시 위에서 정의한 _onSave 함수 실행
        label: const Text("저장하기", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.green.shade300, // 버튼 색상
      ),
    );
  }
}