// [SCREEN CLASS] - StatelessWidget
// '이용약관' 내용을 보여주는 화면입니다.
// (Stateless: 화면에 'tosContent' 데이터를 '보여주기만' 할 뿐, 스스로 변경하는 상태가 없습니다.)

import 'package:flutter/material.dart';
import '../data/tos_data.dart';

class TosScreen extends StatelessWidget {
  // const TosScreen(...): 위젯 생성자
  const TosScreen({super.key});

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // 배경색

      // AppBar: 화면 상단 바
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경색 투명
        elevation: 0, // 그림자 없음

        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("이용약관", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // SafeArea: OS의 상단 상태표시줄(시계, 배터리)이나 하단 홈 버튼 영역을
      // '피해서' UI가 그려지도록 보장해주는 위젯입니다. (특히 아이폰)
      body: SafeArea(
        // Padding: 화면 전체의 바깥쪽 여백
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // Column: 자식 위젯들(약관 내용, 닫기 버튼)을 세로로 배치
          child: Column(
            children: [
              // [약관 내용 영역]
              // Expanded: 'Column' 안에서 '남은 모든 세로 공간'을 차지합니다.
              // (이렇게 해야 '닫기 버튼'은 하단에 고정되고,
              //  약관 내용은 그 사이의 모든 공간을 차지하게 됨)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0), // '내용물(Text)'을 위한 안쪽 여백
                  decoration: BoxDecoration(
                    color: Colors.white, // 흰색 배경
                    borderRadius: BorderRadius.circular(16), // 둥근 모서리
                    border: Border.all(color: Colors.grey.shade300), // 연한 회색 테두리
                  ),
                  // 'Container'의 크기(Expanded로 정해진)보다 'Text(tosContent)'가
                  // '더 길 경우' 스크롤이 가능하도록 만듭니다.
                  child: SingleChildScrollView(
                    child: const Text(
                      tosContent, // 'tos_data.dart'에서 import한 긴 문자열
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.6, // '줄 간격' (1.0이 기본값)
                          color: Colors.black87
                      ),
                    ),
                  ),
                ),
              ),

              // 약관 내용과 닫기 버튼 사이의 수직 간격
              const SizedBox(height: 24),

              // [닫기 버튼 영역]
              SizedBox(
                width: double.infinity, // 버튼 가로 폭 '최대'
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // 초록색 배경
                    foregroundColor: Colors.white, // 흰색 글자
                    padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 내부 세로 여백
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("닫기", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}