// 선호 태그 선택 화면
import 'package:flutter/material.dart';
import '../models/tag_model.dart';
import '../widgets/tag_item.dart';

class TagsScreen extends StatefulWidget {
  final List<String>? initialSelectedTags;

  const TagsScreen({super.key, this.initialSelectedTags});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  // 태그 그룹별 목록 상태
  late Map<String, List<TagModel>> tagGroups;

  @override
  void initState() {
    super.initState();
    final savedTags = widget.initialSelectedTags?.toSet() ?? {};
    // 태그 그룹 초기화 및 선택 상태 세팅
    tagGroups = {
      "맛 & 풍미": ["매콤한", "담백한", "짭짤한", "달달한", "새콤한", "고소한", "기름진", "깔끔한"]
          .map((name) => TagModel(name, isSelected: savedTags.contains(name)))
          .toList(),
      "주재료": ["고기요리", "해산물요리", "채소요리", "면요리", "밥요리"]
          .map((name) => TagModel(name, isSelected: savedTags.contains(name)))
          .toList(),
      "음식 분류": ["반찬", "메인요리", "에피타이저", "디저트"]
          .map((name) => TagModel(name, isSelected: savedTags.contains(name)))
          .toList(),
      "난이도": ["초급", "중급", "고급"]
          .map((name) => TagModel(name, isSelected: savedTags.contains(name)))
          .toList(),
      "조리시간": ["15분", "30분", "60분 이상"]
          .map((name) => TagModel(name, isSelected: savedTags.contains(name)))
          .toList(),
    };
  }

  // 선택된 태그 저장 후 화면 종료
  void _onSave() {
    List<String> selectedTags = [];
    tagGroups.forEach((_, tags) {
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
        title: const Text(
          "선호도 설정 (태그)",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
              // 그룹 제목
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
              // 그룹별 태그 그리드
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
                      // 태그 선택 상태 토글
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
      // 저장 버튼
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onSave,
        label: const Text(
          "저장하기",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        icon: const Icon(Icons.check, color: Colors.white),
        backgroundColor: Colors.green.shade300,
      ),
    );
  }
}