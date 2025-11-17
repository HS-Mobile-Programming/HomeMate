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
  // const TagsScreen(...): 위젯 생성자
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  // [상태 변수 (State Variable)]

  // 이 화면에 표시될 '전체 태그 목록'입니다. (TagModel의 리스트)
  late List<TagModel> tags;

  // [initState]
  // 화면이 '처음' 생성될 때 딱 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    // 'tags' (상태 변수)를 '초기화'합니다.
    // (임시 데이터)
    // 'List.generate(24, ...)' : '24개'의 아이템을 생성하는 리스트
    tags = List.generate(24, (index) {
      // (index: 0~23)
      // 'String.fromCharCode(65 + index)':
      //   ASCII 코드 65는 'A', 66은 'B' ...
      //   -> "태그 A", "태그 B", ... "태그 X" (24개)
      return TagModel("태그 ${String.fromCharCode(65 + index)}");
      // (모든 태그는 'TagModel' 생성자의 기본값에 따라
      //  'isSelected: false' 상태로 생성됩니다.)
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 화면 바깥쪽 여백

        // GridView.builder:
        // '격자(Grid)' 형태의 목록을 '동적'으로(builder) 생성하는 위젯입니다.
        // (ListView.builder의 격자 버전)
        child: GridView.builder(
          // gridDelegate: '격자(Grid)'를 '어떻게' 나눌지 정의하는 '위임자(Delegate)'
          // 'SliverGridDelegateWithFixedCrossAxisCount':
          //   '가로(CrossAxis)'에 '고정된(Fixed)' '개수(Count)'로 나누는 방식
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 가로(CrossAxis)에 '4개'의 아이템을 배치
            mainAxisSpacing: 8, // '세로(MainAxis)' 아이템 간의 간격
            crossAxisSpacing: 8, // '가로(CrossAxis)' 아이템 간의 간격
            childAspectRatio: 0.8, // 각 아이템의 '가로:세로' 비율 (1.0이면 정사각형, 0.8이면 세로가 더 긴 직사각형)
          ),

          itemCount: tags.length, // 'tags' (상태 변수)의 개수(24)만큼 생성

          itemBuilder: (context, index) {
            // 'TagItem' 위젯을 재사용합니다.
            return TagItem(
              tag: tags[index], // 'index'에 해당하는 'tag' 데이터 전달

              // onTap: 'TagItem' 위젯이 '탭'되었을 때 실행될 함수 전달
              onTap: () {
                // 'setState()': 플러터에게 "상태가 변경되었으니 화면을 다시 그려라"라고 알립니다.
                setState(() {
                  // 'tags' 리스트의 'index' 번째 아이템의
                  // 'isSelected' 값을 '!' (NOT) 연산자로 '뒤집습니다'.
                  // (true -> false, false -> true)
                  tags[index].isSelected = !tags[index].isSelected;

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
      ),
    );
  }
}