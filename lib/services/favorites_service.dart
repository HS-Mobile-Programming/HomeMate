/// 즐겨찾기 관리 서비스
/// 로컬 캐시와 Firestore 간 즐겨찾기 레시피 ID를 동기화하고 CRUD 작업을 수행합니다
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'local_favorites_cache.dart';

class FavoritesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalFavoritesCache _localCache = LocalFavoritesCache();

  /// 현재 로그인 사용자 uid
  String get _uid => _auth.currentUser!.uid;

  /// Firestore 즐겨찾기 컬렉션 참조
  CollectionReference<Map<String, dynamic>> get _favoritesCollection =>
      _firestore.collection('users').doc(_uid).collection('favorites');

  /// Firestore에 즐겨찾기를 저장합니다
  Future<void> _saveFavoriteToFirestore(String _recipeId) async {
    await _favoritesCollection.doc(_recipeId).set({"saved": true});
  }

  /// Firestore에서 즐겨찾기를 삭제합니다
  Future<void> _deleteFavoriteFromFirestore(String _recipeId) async {
    await _favoritesCollection.doc(_recipeId).delete();
  }

  /// Firestore에서 즐겨찾기 목록을 로드합니다 (성공 시 로컬 캐시에 동기화)
  Future<List<String>> _loadFavoritesFromFirestore() async {
    final _snapshot = await _favoritesCollection.get();
    return _snapshot.docs.map((_doc) => _doc.id).toList();
  }

  /// 즐겨찾기를 추가합니다 (로컬 캐시 반영 후 Firestore 동기화 시도)
  Future<void> addFavorite(String _recipeId) async {
    final _user = _auth.currentUser;
    if (_user == null) {
      return;
    }
    final _uid = _user.uid;

    final _current = _localCache.loadFavoritesFromLocalCache(_uid);
    if (!_current.contains(_recipeId)) {
      _current.add(_recipeId);
      await _localCache.saveFavoritesToLocalCache(_uid, _current);
    }

    try {
      await _saveFavoriteToFirestore(_recipeId);
    }
    catch (e) {
      debugPrint('Firestore 즐겨찾기 추가 실패 (ID: $_recipeId): $e');
    }
  }

  /// 즐겨찾기를 제거합니다 (로컬 캐시 반영 후 Firestore 동기화 시도)
  Future<void> removeFavorite(String _recipeId) async {
    final _user = _auth.currentUser;
    if (_user == null) return;
    final _uid = _user.uid;

    final _current = _localCache.loadFavoritesFromLocalCache(_uid);
    _current.remove(_recipeId);
    await _localCache.saveFavoritesToLocalCache(_uid, _current);

    try {
      await _deleteFavoriteFromFirestore(_recipeId);
    }
    catch (e) {
      debugPrint('Firestore 즐겨찾기 삭제 실패 (ID: $_recipeId): $e');
    }
  }

  /// 즐겨찾기 목록을 조회합니다 (로컬 우선, 비어있으면 Firestore 로드 후 저장)
  Future<List<String>> getFavoriteList() async {
    final _user = _auth.currentUser;
    if (_user == null) return [];
    final _uid = _user.uid;

    var _list = _localCache.loadFavoritesFromLocalCache(_uid);
    if (_list.isNotEmpty) {
      return _list;
    }
    try {
      _list = await _loadFavoritesFromFirestore();
      await _localCache.saveFavoritesToLocalCache(_uid, _list);
      return _list;
    }
    catch (e) {
      debugPrint('즐겨찾기 목록 로드 실패: $e');
      return [];
    }
  }
}