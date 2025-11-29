// "계정 관련 로직"을 한 곳에 모아두는 파일
// - Firebase Auth 로그인 / 회원가입 / 로그아웃
// - Firestore의 users 컬렉션에 사용자 기본 정보 저장
// 화면(UI) 쪽에서는 FirebaseAuth나 FirebaseFirestore를 직접 쓰지 않고
// 이 AccountService를 통해서 계정 관련 기능을 사용할 수 있습니다.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // 회원가입
  // 이메일 / 비밀번호 / 닉네임을 받아 Firebase Auth에 계정을 생성하고,
  // Firestore의 users 컬렉션에 사용자 기본 정보를 저장합니다.
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
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

    // Firestore에 users/{uid} 문서를 생성합니다.
    // 여기에는 이메일, 닉네임, 계정 생성 시간을 저장합니다.
    // 나중에 /users/{uid}/ingredients, /users/{uid}/favorites 문서들을 위의 문서 기준으로 덧붙일 예정입니다.
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'nickname': nickname,
      'createdAt': FieldValue.serverTimestamp()
    });
  }

  // 로그아웃
  // 현재 로그인된 사용자를 로그아웃시킵니다.
  // (Firebase Auth에서 세션을 종료)
  Future<void> signOut() async {
    await _auth.signOut();
  }
}