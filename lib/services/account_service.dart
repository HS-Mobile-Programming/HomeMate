// "계정 관련 로직"을 한 곳에 모아두는 파일
// - Firebase Auth 로그인 / 회원가입 / 로그아웃
// - Firestore의 users 컬렉션에 사용자 기본 정보 저장
// 화면(UI) 쪽에서는 FirebaseAuth나 FirebaseFirestore를 직접 쓰지 않고
// 이 AccountService를 통해서 계정 관련 기능을 사용할 수 있습니다.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 에러 메시지를 전달하기 위한 예외 처리 UI
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AccountService {
  // 외부에서 new AccountService()로 여러 개를 만들지 못하게 막기 위해 내부생성자를 사용합니다.
  AccountService._internal();

  // AccountService.instance 로 어디서든 동일한 인스턴스를 사용할 수 있습니다.
  static final AccountService instance = AccountService._internal();

  // Firebase 인스턴스들
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 로그인되어 있지 않은 경우 null을 반환합니다.
  User? get currentUser => _auth.currentUser;

  // 사용자의 로그인 / 로그아웃 상태 변화를 실시간으로 감지하고 싶을 때 사용합니다.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 로그인
  // 이메일과 비밀번호를 받아 Firebase Auth에 로그인 요청을 보냅니다.
  // 에러가 발생하면 FirebaseAuthException 처리합니다.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'invalid-email':
          msg = '이메일 형식이 올바르지 않습니다.';
          break;
        case 'user-disabled':
          msg = '비활성화된 계정입니다. 관리자에게 문의해주세요.';
          break;
        case 'user-not-found':
          msg = '해당 이메일 계정을 찾을 수 없습니다.';
          break;
        case 'wrong-password':
          msg = '비밀번호가 올바르지 않습니다.';
          break;
        case 'network-request-failed':
          msg = '네트워크 연결 상태를 확인한 뒤 다시 시도해주세요.';
          break;
        default:
          msg = '로그인에 실패했습니다. 잠시 후 다시 시도해주세요.';
      }
      throw AuthException(msg);
    } catch (_) {
      throw AuthException('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 회원가입
  // 이메일 / 비밀번호 / 닉네임을 받아 Firebase Auth에 계정을 생성하고,
  // Firestore의 users 컬렉션에 사용자 기본 정보를 저장합니다.
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      // Firebase Auth에 새 계정 생성을 요청합니다.
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 생성된 사용자 객체를 가져옵니다.
      final user = credential.user;
      if (user == null) {
        // 혹시 모를 예외 처리
        throw Exception('회원가입에 실패했습니다.');
      }

      // Firestore에 users/{uid} (이메일, 닉네임, 계정 생성 시간)문서를 생성합니다.
      // 나중에 /users/{uid}/ingredients, /users/{uid}/favorites 문서들을 위의 문서 기준으로 덧붙일 예정입니다.
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'nickname': nickname,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'invalid-email':
          msg = '이메일 형식이 올바르지 않습니다.';
          break;
        case 'email-already-in-use':
          msg = '이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.';
          break;
        case 'weak-password':
          msg = '비밀번호가 너무 약합니다. 더 복잡하게 설정해주세요.';
          break;
        case 'network-request-failed':
          msg = '네트워크 연결 상태를 확인한 뒤 다시 시도해주세요.';
          break;
        default:
          msg = '회원가입에 실패했습니다. 잠시 후 다시 시도해주세요.';
      }
      throw AuthException(msg);
    } catch (_) {
      throw AuthException('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 로그아웃
  // Firebase Auth에서 세션 종료
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 계정 탈퇴 -> Firestore 사용자 데이터, Auth 계정 삭제
  Future<void> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException('로그인된 사용자가 없습니다.');
    }
    if (user.email == null) {
      throw AuthException('이메일 로그인 계정이 아닙니다.');
    }

    // 비밀번호 재인증 -> Firebase Auth 계정 삭제 정책 상 필요한
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'wrong-password':
          msg = '비밀번호가 올바르지 않습니다.';
          break;
        case 'user-mismatch':
        case 'user-not-found':
          msg = '사용자 정보를 다시 확인해주세요.';
          break;
        case 'invalid-credential':
          msg = '로그인 정보가 유효하지 않습니다. 다시 시도해주세요.';
          break;
        default:
          msg = '재인증 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }
      throw AuthException(msg);
    }

    // Firestore에서 탈퇴할 사용자의 데이터 모두 삭제
    await _deleteUserData(user.uid);

    // Firebase Auth 계정 삭제
    await user.delete();
  }

  // Firestore에서 탈퇴할 사용자의 uid 문서와 하위 컬렉션 삭제
  Future<void> _deleteUserData(String uid) async {
    final userDoc = _db.collection('users').doc(uid);
    final batch = _db.batch();  // 관리할 문서 개수가 많지 않기 때문에 batch 사용

    // favorites 컬렉션 삭제
    final favSnap = await userDoc.collection('favorites').get();
    for (final doc in favSnap.docs) {
      batch.delete(doc.reference);
    }

    // ingredients 컬렉션 삭제
    final ingSnap = await userDoc.collection('ingredients').get();
    for (final doc in ingSnap.docs) {
      batch.delete(doc.reference);
    }

    // uid 문서 삭제
    batch.delete(userDoc);

    await batch.commit();
  }

  // 사용자의 이름을 가져오는 함수
  Future<String> getName() async {
    final user = _auth.currentUser;

    if (user == null) {
      return "사용자 정보 없음";
    }
    try {
      var doc = await _db.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data();

        if (data != null) {
          final name = data['nickname'];
          if (name != null) {
            return name;
          }
        }
      }
      return "사용자";
    }
    catch (e) {
      return "오류";
    }
  }
}