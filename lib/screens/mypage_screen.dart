// [SCREEN CLASS] - StatefulWidget
// '마이페이지' 탭 (index 4)에 표시되는 화면입니다.
// 프로필, 즐겨찾기, 알림설정, 로그아웃, 계정탈퇴 메뉴를 제공합니다.
//
// 'StatefulWidget':
// '알림설정' 다이얼로그(AlertDialog) 내부의 '상태'(isPushOn, days)를
// 'StatefulBuilder'를 이용해 관리하고 있습니다.

import 'package:flutter/material.dart';
import 'favorites_screen.dart';

class MyPageScreen extends StatefulWidget {
  // const MyPageScreen(...): 위젯 생성자
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  // [헬퍼 메서드 1: 액션 확인 다이얼로그]
  // '로그아웃', '계정탈퇴'처럼 '확인'이 필요한 공통 다이얼로그를 띄우는 함수입니다.
  void _showActionDialog(String title, String content, String confirmText, Color confirmColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [ // 하단 버튼
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                Navigator.pop(context); // 1. 다이얼로그 닫기
                // 2. (임시) 스낵바 표시
                // (나중에 여기에 실제 '로그아웃' 또는 '계정탈퇴' 로직이 들어가야 함)
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$confirmText 완료되었습니다.")));
              },
              // 'confirmText'와 'confirmColor' 파라미터를 사용하여
              // '로그아웃'(빨간색) 또는 '계정탈퇴'(빨간색) 텍스트를 동적으로 표시
              child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // [헬퍼 메서드 2: 알림 설정 다이얼로그]
  // '알림설정' 메뉴를 눌렀을 때 띄우는 전용 다이얼로그 함수입니다.
  void _showNotificationDialog() {
    // 다이얼로그 '내부'에서 사용될 '임시' 상태 변수
    bool isPushOn = true; // (기본값: 켜짐)
    int days = 3; // (기본값: 3일)

    showDialog(
      context: context,
      builder: (context) {
        // [StatefulBuilder]
        // 다이얼로그(AlertDialog)는 기본적으로 StatelessWidget입니다.
        // 다이얼로그 '내부'의 상태(isPushOn, days)가 '변경'될 때,
        // '다이얼로그 창만' 다시 그리게(rebuild) 하기 위해
        // 'StatefulBuilder'를 사용합니다.
        return StatefulBuilder(
          // 'builder' 함수는 'setState' 함수를 파라미터로 받습니다.
          // 이 'setState'는 'StatefulBuilder' 자신만 다시 그립니다.
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.green.shade50, // 연한 초록 배경
                title: const Center(child: Text("알림설정", style: TextStyle(fontSize: 18))),
                content: Column(
                  mainAxisSize: MainAxisSize.min, // 컨텐츠 높이만큼만 다이얼로그 크기 잡기
                  children: [
                    // [푸시 알림 On/Off]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // 양 끝 정렬
                      children: [
                        const Text("푸시 알림", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Checkbox(
                            value: isPushOn, // 임시 상태 변수
                            // 'StatefulBuilder'의 'setState'를 호출하여
                            // 'isPushOn' 값을 변경하고 '다이얼로그만' 갱신
                            onChanged: (val) => setState(() => isPushOn = val!)
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    // [유통기한 알림 일자]
                    const Text("재료의 유통기한이", style: TextStyle(fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                      children: [
                        IconButton(
                            icon: const Icon(Icons.remove),
                            // 'setState'를 호출하여 'days' 값을 변경 (1 미만 X)
                            onPressed: () => setState(() { if(days>1) days--; })
                        ),
                        Text("$days", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.add),
                            // 'setState'를 호출하여 'days' 값을 변경
                            onPressed: () => setState(() => days++)
                        ),
                        const Text("일"),
                      ],
                    ),
                    const Text("남았을 때 알리기"),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.red))),
                  // (나중에 여기에 '저장' 로직이 필요)
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인", style: TextStyle(color: Colors.green))),
                ],
              );
            }
        );
      },
    );
  }

  // [build]
  // 이 위젯의 UI를 실제로 그리는 메서드입니다.
  @override
  Widget build(BuildContext context) {
    return Scaffold( // (배경색 등을 위해 Scaffold로 감싸기)
      body: SingleChildScrollView( // (메뉴가 많아질 경우 스크롤)
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // '마이페이지' 제목 왼쪽 정렬
          children: [
            const Text("마이페이지", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // [프로필 카드]
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: const [
                    Icon(Icons.account_circle, size: 64, color: Colors.green), // 프로필 아이콘
                    SizedBox(width: 16),
                    Text(
                      "사용자 닉네임", // (임시 텍스트)
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // [메뉴 버튼 영역]
            // '_buildMenuButton' 헬퍼 메서드를 사용하여 메뉴 버튼 생성

            //  즐겨찾기 버튼
            _buildMenuButton("   즐겨찾기", () {
              // 'FavoritesScreen'으로 '이동' (push)
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            }),
            _buildMenuButton("   알림설정", _showNotificationDialog), // 헬퍼 메서드 2 호출
            _buildMenuButton("   로그아웃", () => _showActionDialog("로그아웃", "로그아웃 하시겠습니까?", "로그아웃", Colors.red)), // 헬퍼 메서드 1 호출
            _buildMenuButton("   계정탈퇴", () => _showActionDialog("계정탈퇴", "탈퇴 후 계정을 복원할 수 없습니다.", "계정탈퇴", Colors.red)), // 헬퍼 메서드 1 호출
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 3: 메뉴 버튼 UI]
  // '반복되는 메뉴 버튼 UI'를 생성하는 함수입니다.
  Widget _buildMenuButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity, // 가로 폭 '최대'
      margin: const EdgeInsets.only(bottom: 12), // 버튼 하단 여백
      child: ElevatedButton(
        onPressed: onTap, // 전달받은 'onTap' 함수 연결
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green.shade50, // 연한 초록 배경
          padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 내부 세로 여백
          alignment: Alignment.centerLeft, // 버튼 내부의 '텍스트'를 '왼쪽 정렬'
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}