// lib/services/account_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountService {
  AccountService._internal();

  static final AccountService instance = AccountService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 로그인
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
  Future<void> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('회원가입에 실패했습니다.');
    }

    // users 컬렉션에 기본 정보 저장
    await _db.collection('users').doc(user.uid).set({
      'email': user.email,
      'nickname': nickname,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 로그아웃
  Future<void> signOut() async {
    await _auth.signOut();
  }
}