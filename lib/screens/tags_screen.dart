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
  // 태그를 그룹별로 관리하는 Map
  // Key: 그룹 이름 (예: "맛 & 풍미", "주재료")
  // Value: 해당 그룹의 태그 리스트 (List<TagModel>)
  late Map<String, List<TagModel>> tagGroups;

  @override
  void initState() {
    super.initState();
    // 부모 화면에서 전달받은 초기 선택 태그를 Set으로 변환 (빠른 검색을 위해)
    final savedTags = widget.initialSelectedTags?.toSet() ?? {};
    
    // 태그 그룹 초기화 - 각 태그의 isSelected 상태를 초기값으로 설정
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

      "난이도": [
        "초급", "중급", "고급"
      ].map((name) => TagModel(name, isSelected: savedTags.contains(name))).toList(),

      "조리시간": [
        "15분", "30분", "60분 이상"
      ].map((name) => TagModel(name, isSelected: savedTags.contains(name))).toList(),
    };
  }

  /// 저장하기 버튼 클릭 시 호출되는 메서드
  /// - 모든 그룹에서 선택된 태그(isSelected == true)를 수집
  /// - 선택된 태그 목록을 부모 화면으로 반환
  /// - 저장 완료 메시지(SnackBar) 표시
  void _onSave() {
    List<String> selectedTags = [];

    // 모든 태그 그룹을 순회하며 선택된 태그만 수집
    tagGroups.forEach((category, tags) {
      for (var tag in tags) {
        if (tag.isSelected) {
          selectedTags.add(tag.name);
        }
      }
    });

    // 저장 완료 알림 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("취향 태그가 저장되었습니다."),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // 선택된 태그 목록을 부모 화면으로 전달하며 화면 닫기
    Navigator.pop(context, selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("선호도 설정 (태그)", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context), // 뒤로가기 - 선택한 태그 저장하지 않음
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0), // 하단 버튼 공간 확보
        children: tagGroups.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 그룹 제목 표시 (예: "맛 & 풍미", "주재료")
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
              // 그룹별 태그를 4열 그리드로 표시
              GridView.builder(
                shrinkWrap: true, // ListView 내부에서 높이 자동 조절
                physics: const NeverScrollableScrollPhysics(), // ListView와 스크롤 충돌 방지
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 가로 4개씩 배치
                  mainAxisSpacing: 8, // 세로 간격
                  crossAxisSpacing: 8, // 가로 간격
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final tag = entry.value[index];
                  return TagItem(
                    tag: tag,
                    onTap: () {
                      // 태그 탭 시 선택 상태 토글
                      setState(() {
                        tag.isSelected = !tag.isSelected;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24), // 그룹 간 간격
            ],
          );
        }).toList(),
      ),
      // 하단 고정 저장 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSave,
        label: const Text("저장하기", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }
}