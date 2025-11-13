import 'package:flutter/material.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  // 공통 다이얼로그 (로그아웃/탈퇴용)
  void _showActionDialog(String title, String content, String confirmText, Color confirmColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.grey))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$confirmText 완료되었습니다.")));
              },
              child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  // 알림 설정 다이얼로그
  void _showNotificationDialog() {
    bool isPushOn = true;
    int days = 3;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFE0F7FA),
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
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소", style: TextStyle(color: Colors.red))),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인", style: TextStyle(color: Colors.green))),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // [수정됨] SingleChildScrollView 추가하여 화면 전체 스크롤 가능
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("마이페이지", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildMenuButton("즐겨찾기", () { /* 즐겨찾기 화면 이동 */ }),
            _buildMenuButton("알림설정", _showNotificationDialog),
            _buildMenuButton("로그아웃", () => _showActionDialog("로그아웃", "로그아웃 하시겠습니까?", "로그아웃", Colors.red)),
            _buildMenuButton("계정탈퇴", () => _showActionDialog("계정탈퇴", "탈퇴 후 계정을 복원할 수 없습니다.", "계정탈퇴", Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE0F7FA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}