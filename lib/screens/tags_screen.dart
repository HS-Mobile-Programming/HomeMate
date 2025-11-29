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
  final List<String>? initialSelectedTags; // 초기 선택된 태그 목록
  
  const TagsScreen({super.key, this.initialSelectedTags});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  // [상태 변수 (State Variable)]

  // 카테고리별 태그 목록
  late List<TagModel> section1Tags; // 첫 번째 섹션
  late List<TagModel> section2Tags; // 두 번째 섹션
  late List<TagModel> section3Tags; // 세 번째 섹션

  // [initState]
  // 화면이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    
    // 첫 번째 섹션 태그
    final List<String> section1TagNames = [
      '매콤한',
      '담백한',
      '짭짤한',
      '달달한',
      '새콤한',
      '고소한',
      '기름진',
      '깔끔한',
    ];
    
    // 두 번째 섹션 태그
    final List<String> section2TagNames = [
      '고기요리',
      '해산물요리',
      '채소요리',
      '면요리',
      '밥요리',
    ];
    
    // 세 번째 섹션 태그
    final List<String> section3TagNames = [
      '반찬',
      '메인요리',
      '에피타이저',
      '디저트',
    ];
    
    // 각 카테고리별로 TagModel 리스트 생성
    section1Tags = section1TagNames.map((tagName) {
      bool isSelected = widget.initialSelectedTags?.contains(tagName) ?? false;
      return TagModel(tagName, isSelected: isSelected);
    }).toList();
    
    section2Tags = section2TagNames.map((tagName) {
      bool isSelected = widget.initialSelectedTags?.contains(tagName) ?? false;
      return TagModel(tagName, isSelected: isSelected);
    }).toList();
    
    section3Tags = section3TagNames.map((tagName) {
      bool isSelected = widget.initialSelectedTags?.contains(tagName) ?? false;
      return TagModel(tagName, isSelected: isSelected);
    }).toList();
  }
  
  // 모든 태그를 하나의 리스트로 반환 (뒤로가기 시 사용)
  List<TagModel> get allTags => [...section1Tags, ...section2Tags, ...section3Tags];

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
          onPressed: () {
            // 선택된 태그 목록을 추출하여 반환
            List<String> selectedTags = allTags
                .where((tag) => tag.isSelected)
                .map((tag) => tag.name)
                .toList();
            Navigator.pop(context, selectedTags);
          },
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5), // 앱 공통 배경색

      // body: 화면 본문 영역
      body: ListView(
        padding: const EdgeInsets.all(16.0), // 화면 바깥쪽 여백
        children: [
          // 첫 번째 섹션
          _buildTagSection(section1Tags),
          const Divider(height: 32, thickness: 1),
          
          // 두 번째 섹션
          _buildTagSection(section2Tags),
          const Divider(height: 32, thickness: 1),
          
          // 세 번째 섹션
          _buildTagSection(section3Tags),
        ],
      ),
    );
  }
  
  // 태그 섹션을 생성하는 헬퍼 메서드
  Widget _buildTagSection(List<TagModel> tagList) {
    return GridView.builder(
      shrinkWrap: true, // ListView 내부에서 사용하기 위해 필요
      physics: const NeverScrollableScrollPhysics(), // 스크롤 비활성화 (ListView가 스크롤 처리)
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 가로(CrossAxis)에 '4개'의 아이템을 배치
        mainAxisSpacing: 8, // '세로(MainAxis)' 아이템 간의 간격
        crossAxisSpacing: 8, // '가로(CrossAxis)' 아이템 간의 간격
        childAspectRatio: 0.8, // 각 아이템의 '가로:세로' 비율
      ),
      itemCount: tagList.length,
      itemBuilder: (context, index) {
        return TagItem(
          tag: tagList[index],
          onTap: () {
            setState(() {
              tagList[index].isSelected = !tagList[index].isSelected;
            });
          },
        );
      },
    );
  }
}