// [SCREEN CLASS] - StatefulWidget
// '마이페이지' 탭 (index 4)에 표시되는 화면입니다.

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
    final colorScheme = Theme.of(context).colorScheme; // 다이얼로그 내에서도 테마 사용 가능

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface, // 테마 배경색
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [ // 하단 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
              onPressed: () {
                Navigator.pop(context); // 1. 다이얼로그 닫기
                // 2. (임시) 스낵바 표시
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$confirmText 완료되었습니다.")));
              },
              // 전달받은 confirmColor 사용
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

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        // [StatefulBuilder]
        // 다이얼로그 '내부'의 상태가 변경될 때 다이얼로그만 다시 그리기 위해 사용
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
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
                            value: isPushOn,
                            activeColor: colorScheme.primary, // 체크 색상도 테마 따름
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
                            onPressed: () => setState(() { if(days>1) days--; })
                        ),
                        Text("$days", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => days++)
                        ),
                        const Text("일"),
                      ],
                    ),
                    const Text("남았을 때 알리기"),
                  ],
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("취소", style: TextStyle(color: colorScheme.error))
                  ),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("확인", style: TextStyle(color: colorScheme.primary))
                  ),
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
    // 1. 테마 색상표 가져오기
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
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
              color: colorScheme.surface, // 테마의 표면 색상 (흰색 등)
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.account_circle, size: 64, color: colorScheme.primary),
                    const SizedBox(width: 16),
                    const Text(
                      "사용자 닉네임",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // [메뉴 버튼 영역]
            //  즐겨찾기 버튼
            _buildMenuButton("   즐겨찾기", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            }),
            _buildMenuButton("   알림설정", _showNotificationDialog),
            _buildMenuButton("   로그아웃", () => _showActionDialog("로그아웃", "로그아웃 하시겠습니까?", "로그아웃", colorScheme.error)),
            _buildMenuButton("   계정탈퇴", () => _showActionDialog("계정탈퇴", "탈퇴 후 계정을 복원할 수 없습니다.", "계정탈퇴", colorScheme.error)),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 3: 메뉴 버튼 UI]
  // '반복되는 메뉴 버튼 UI'를 생성하는 함수입니다.
  Widget _buildMenuButton(String text, VoidCallback onTap) {
    // 헬퍼 메서드 안에서도 context를 통해 테마 접근 가능
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity, // 가로 폭 '최대'
      margin: const EdgeInsets.only(bottom: 12), // 버튼 하단 여백
      child: ElevatedButton(
        onPressed: onTap, // 전달받은 'onTap' 함수 연결
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primaryContainer,
          padding: const EdgeInsets.symmetric(vertical: 16), // 버튼 내부 세로 여백
          alignment: Alignment.centerLeft, // 버튼 내부의 '텍스트'를 '왼쪽 정렬'
          elevation: 0, // 그림자 제거 (선택사항)
        ),
        child: Text(text, style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 16)),
      ),
    );
  }
}