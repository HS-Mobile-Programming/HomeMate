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

  @override
  void initState() {
    super.initState();
    final savedTags = widget.initialSelectedTags?.toSet() ?? {};
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

  void _onSave() {
    List<String> selectedTags = [];

    tagGroups.forEach((category, tags) {
      for (var tag in tags) {
        if (tag.isSelected) {
          selectedTags.add(tag.name);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("취향 태그가 저장되었습니다."),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
        children: tagGroups.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: entry.value.length,
                itemBuilder: (context, index) {
                  final tag = entry.value[index];
                  return TagItem(
                    tag: tag,
                    onTap: () {
                      setState(() {
                        tag.isSelected = !tag.isSelected;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSave,
        label: const Text("저장하기", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }
}