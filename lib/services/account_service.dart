// 계정 인증·프로필 저장을 담당하는 서비스: Firebase Auth 세션 관리, Firestore 사용자 문서 CRUD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AccountService {
  AccountService._internal();
  static final AccountService instance = AccountService._internal();

  // 인증·DB 핸들
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 로그인 사용자
  User? get currentUser => _firebaseAuth.currentUser;

  // 실시간 인증 상태 스트림
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 이메일/비밀번호 로그인
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _syncFcmTokenToUserDocument();

    } on FirebaseAuthException catch (e) {
      final msg = _mapSignInError(e.code);
      throw AuthException(msg);
    }
    catch (_) {
      throw AuthException('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 회원가입: Auth 계정 생성 후 Firestore 사용자 문서 생성
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw Exception('회원가입에 실패했습니다.');
      }
      await _createUserDocumentInFirestore(
        uid: user.uid,
        email: user.email,
        nickname: nickname,
      );

      await _syncFcmTokenToUserDocument();

    }
    on FirebaseAuthException catch (e) {
      final msg = _mapSignUpError(e.code);
      throw AuthException(msg);
    }
    catch (_) {
      throw AuthException('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    final user = _firebaseAuth.currentUser;

    // FCM 토큰 제거
    if (user != null && !kIsWeb) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        final userRef = _firestore.collection('users').doc(user.uid);
        final snap = await userRef.get();
        final saved = snap.data()?['fcmToken'] as String?;

        if (saved != null && token != null && saved == token) {
          await userRef.set(
            {
              'fcmToken': FieldValue.delete(),
              'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        }
      } catch (_) {
        // 로그아웃 방지 무시
      }
    }

    await _firebaseAuth.signOut();
  }

  // 계정 탈퇴: 재인증 → Firestore 데이터 삭제 → Auth 계정 삭제
  Future<void> deleteAccount(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw AuthException('로그인된 사용자가 없습니다.');
    if (user.email == null) throw AuthException('이메일 로그인 계정이 아닙니다.');

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    }
    on FirebaseAuthException catch (e) {
      final msg = _mapReauthError(e.code);
      throw AuthException(msg);
    }
    catch (_) {
      throw AuthException('알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
    }

    await _deleteUserDataFromFirestore(user.uid);
    await user.delete();
  }

  // Firestore에서 사용자 이름 로드 (기존 getName 호환 유지)
  Future<String> loadUserNameFromFirestore() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return "사용자 정보 없음";
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final name = data?['nickname'] as String?;
      return name ?? "사용자";
    }
    catch (_) {
      return "오류";
    }
  }

  // 기존 호출 호환용
  Future<String> getName() => loadUserNameFromFirestore();

  // ----------------- Firestore 헬퍼 -----------------

  // Firestore 사용자 문서 생성
  Future<void> _createUserDocumentInFirestore({
    required String uid,
    required String? email,
    required String nickname,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'nickname': nickname,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 로그인 사용자의 FCM 토큰을 Firestore users/{uid} 문서에 저장 및 갱신
  Future<void> _syncFcmTokenToUserDocument() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    if (kIsWeb) return;

    try {
      await FirebaseMessaging.instance.requestPermission();

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;

      await _firestore.collection('users').doc(user.uid).set(
        {
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // 토큰 저장 실패로 인한 로그인/회원가입 방지 무시
    }
  }

  // Firestore에 저장된 사용자 데이터(문서+하위 컬렉션) 삭제
  Future<void> _deleteUserDataFromFirestore(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final batch = _firestore.batch();

    final favoritesSnapshot = await userDoc.collection('favorites').get();
    for (final doc in favoritesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final ingredientsSnapshot = await userDoc.collection('ingredients').get();
    for (final doc in ingredientsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(userDoc);
    await batch.commit();
  }

  // ----------------- 에러 매핑 -----------------

  String _mapSignInError(String code) {
    switch (code) {
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'user-disabled':
        return '비활성화된 계정입니다. 관리자에게 문의해주세요.';
      case 'user-not-found':
        return '해당 이메일 계정을 찾을 수 없습니다.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'network-request-failed':
        return '네트워크 연결 상태를 확인한 뒤 다시 시도해주세요.';
      default:
        return '로그인에 실패했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  String _mapSignUpError(String code) {
    switch (code) {
      case 'invalid-email':
        return '이메일 형식이 올바르지 않습니다.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다. 다른 이메일을 사용해주세요.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 더 복잡하게 설정해주세요.';
      case 'network-request-failed':
        return '네트워크 연결 상태를 확인한 뒤 다시 시도해주세요.';
      default:
        return '회원가입에 실패했습니다. 잠시 후 다시 시도해주세요.';
    }
  }

  String _mapReauthError(String code) {
    switch (code) {
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다.';
      case 'user-mismatch':
        return '사용자 정보를 다시 확인해주세요.';
      case 'user-not-found':
        return '사용자 정보를 확인할 수 없습니다.';
      case 'invalid-credential':
        return '로그인 정보가 유효하지 않습니다. 다시 시도해주세요.';
      default:
        return '재인증 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }
  }
}