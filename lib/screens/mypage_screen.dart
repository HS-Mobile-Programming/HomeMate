// 마이페이지: 계정 정보, 알림 설정, 도움말
import 'package:flutter/material.dart';
import '../data/help_data.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 사용자 이름 상태
  String myName = "";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // 사용자 이름 로드
  Future<void> _loadUserName() async {
    final fetchedName = await AccountService.instance.getName();
    if (!mounted) {
      return;
    }
    setState(() {
      myName = fetchedName;
    });
  }

  // 계정 탈퇴 플로우
  Future<void> _onDeleteAccountPressed() async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: const Text(
          '계정탈퇴',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            child: const Text(
              '탈퇴',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return;
    }

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        final passwordController = TextEditingController();
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          title: const Text(
            '비밀번호 확인',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '비밀번호를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(passwordController.text),
              child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (password == null || password.isEmpty) {
      return;
    }

    try {
      await AccountService.instance.deleteAccount(password);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('계정이 탈퇴되었습니다. 이용해 주셔서 감사합니다.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
    on AuthException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('계정 삭제 중 알 수 없는 오류가 발생했습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 확인이 필요한 액션 다이얼로그
  void _showActionDialog(
    String title,
    String content,
    String confirmText,
    Color confirmColor,
  )
  {
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
            child: Text(
              confirmText,
              style: TextStyle(
                color: confirmColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 알림 테스트
  Future<void> _testNotification() async {
    try {
      await NotificationService.instance.checkExpiringIngredients();
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("알림 테스트가 실행되었습니다. 유통기한이 임박한 재료가 있으면 알림이 표시됩니다."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("알림 테스트 오류: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 알림 설정 다이얼로그
  Future<void> _showNotificationDialog() async {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = await NotificationService.instance
        .getNotificationSettingsFromFirestore();
    bool isPushOn = settings['isPushOn'] as bool;
    int days = settings['days'] as int;

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Center(
                child: Text("알림설정", style: TextStyle(fontSize: 18)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "푸시 알림",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Checkbox(
                        value: isPushOn,
                        activeColor: colorScheme.primary,
                        onChanged: (val) => setState(() => isPushOn = val!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("재료의 유통기한이", style: TextStyle(fontSize: 14)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => setState(() {
                          if (days > 1) {
                            days--;
                          }
                        }),
                      ),
                      Text(
                        "$days",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => setState(() => days++),
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
                  child: Text("취소", style: TextStyle(color: colorScheme.error)),
                ),
                TextButton(
                  onPressed: () async {
                    await NotificationService.instance
                        .saveNotificationSettingsToFirestore(
                          isPushOn: isPushOn,
                          days: days,
                        );
                    Navigator.of(context).pop();
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("알림 설정이 저장되었습니다."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Text("확인", style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 도움말 다이얼로그
  void _showHelpDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Center(
          child: Text("도움말", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(helpTitle1, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(helpContent1),
            SizedBox(height: 12),
            Text(helpTitle2, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(helpContent2),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("닫기", style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("마이페이지"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: Text(myName.isEmpty ? "이름 불러오는 중..." : myName),
              subtitle: const Text("계정 정보"),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text("즐겨찾기"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Colors.green,
                  ),
                  title: const Text("알림 설정"),
                  onTap: _showNotificationDialog,
                ),
                //ListTile(
                //  leading: const Icon(Icons.notifications, color: Colors.blue),
                //  title: const Text("알림 테스트"),
                //  onTap: _testNotification,
                //),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text("로그아웃"),
                  onTap: () => _showActionDialog(
                    "로그아웃",
                    "로그아웃하시겠습니까?",
                    "로그아웃",
                    colorScheme.primary,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text("계정 탈퇴"),
                  onTap: _onDeleteAccountPressed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.indigo),
              title: const Text("도움말"),
              onTap: _showHelpDialog,
            ),
          ),
        ],
      ),
    );
  }
}