import 'package:flutter/material.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import '../data/help_data.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String myName = "";

  @override
  void initState() {
    super.initState();
    getName();
  }

  Future<void> getName() async {
    String name = await AccountService.instance.getName();

    if (mounted) {
      setState(() {
        myName = name;
      });
    }
  }

  // 계정 탈퇴 진행 메서드
  Future<void> _onDeleteAccountPressed() async {
    final colorScheme = Theme.of(context).colorScheme;

    // 1차 탈퇴 확인
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: const Text('계정탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          '탈퇴 후에는 계정과 모든 데이터가 삭제되며,\n'
              '복구할 수 없습니다.\n\n정말로 탈퇴하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 비밀번호 재입력 다이얼로그
    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: const Text('비밀번호 확인', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '비밀번호를 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
    // 사용자의 취소 or 비밀번호 미입력 시
    if (password == null || password.isEmpty) {
      return;
    }

    // 삭제 처리
    try {
      await AccountService.instance.deleteAccount(password);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('계정이 탈퇴되었습니다. 이용해 주셔서 감사합니다.'),
          duration: Duration(seconds: 2),
        ),
      );

      // 로그인 화면으로
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    } on AuthException catch (e) {  // AuthException 발생 처리
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('계정 삭제 중 알 수 없는 오류가 발생했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
            onPressed: () async {
              Navigator.of(context).pop();
              await AccountService.instance.signOut();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$confirmText 완료되었습니다."),
                    duration: const Duration(seconds: 1),
                  ),
                );

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(confirmText, style: TextStyle(color: confirmColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 알림 설정 다이얼로그
  void _showNotificationDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = await NotificationService.instance.getNotificationSettings();
    bool isPushOn = settings['isPushOn'] as bool;
    int days = settings['days'] as int;

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
                      onPressed: () async {
                        await NotificationService.instance.saveNotificationSettings(
                          isPushOn: isPushOn,
                          days: days,
                        );
                        Navigator.of(context).pop();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("알림 설정이 저장되었습니다."),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }
                      },
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
                    Text(myName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildMenuButton("   즐겨찾기", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            }),

            _buildMenuButton("   알림설정", _showNotificationDialog),
            _buildMenuButton("   도움말", _showHelpDialog),
            _buildMenuButton("   로그아웃", () => _showActionDialog("로그아웃", "로그아웃 하시겠습니까?", "로그아웃", colorScheme.error)),
            _buildMenuButton("   계정탈퇴", _onDeleteAccountPressed),
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