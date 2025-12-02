// [SCREEN CLASS] - StatefulWidget
// '마이페이지' 탭 (index 4)에 표시되는 화면입니다.

import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import '../data/help_data.dart';

class MyPageScreen extends StatefulWidget {
  // const MyPageScreen(...): 위젯 생성자
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  // [헬퍼 메서드 1: 액션 확인 다이얼로그]
  void _showActionDialog(String title, String content, String confirmText, Color confirmColor) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("취소", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("$confirmText 완료되었습니다."),
                      duration: const Duration(seconds: 1),
                    )
                );

                // 로그인 화면으로 이동
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // [헬퍼 메서드 2: 알림 설정 다이얼로그]
  void _showNotificationDialog() {
    bool isPushOn = true;
    int days = 3;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                title: const Center(child: Text("알림설정", style: TextStyle(fontSize: 18))),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("푸시 알림", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Checkbox(
                            value: isPushOn,
                            activeColor: colorScheme.primary,
                            onChanged: (val) => setState(() => isPushOn = val!)
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text("재료의 유통기한이", style: TextStyle(fontSize: 14)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("취소", style: TextStyle(color: colorScheme.error))
                  ),
                  TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text("확인", style: TextStyle(color: colorScheme.primary))
                  ),
                ],
              );
            }
        );
      },
    );
  }

  // [헬퍼 메서드 3: 도움말 다이얼로그]
  void _showHelpDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(child: Text("도움말", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                helpTitle1,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                helpContent1,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
              SizedBox(height: 16),
              Text(
                helpTitle2,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                helpContent2,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("닫기", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // [build]
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("마이페이지", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // 프로필 카드
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: colorScheme.surface,
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

            // 메뉴 버튼 영역
            // 즐거찾기 버튼
            _buildMenuButton("   즐겨찾기", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            }),

            // 알람설정 버튼
            _buildMenuButton("   알림설정", _showNotificationDialog),

            // 도움말 버튼
            _buildMenuButton("   도움말", _showHelpDialog),

            // 로그아웃 버튼
            _buildMenuButton("   로그아웃", () => _showActionDialog("로그아웃", "로그아웃 하시겠습니까?", "로그아웃", colorScheme.error)),

            // 계정탈퇴 버튼
            _buildMenuButton("   계정탈퇴", () => _showActionDialog("계정탈퇴", "탈퇴 후 계정을 복원할 수 없습니다.", "계정탈퇴", colorScheme.error)),
          ],
        ),
      ),
    );
  }

  // [헬퍼 메서드 4: 메뉴 버튼 UI]
  Widget _buildMenuButton(String text, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: BorderSide(color: Colors.green.withValues(alpha: 1.0), width: 2),
          ),
        ),
        child: Text(text, style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 16)),
      ),
    );
  }
}