import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'local_favorites_cache.dart';

class FavoritesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocalFavoritesCache _localCache = LocalFavoritesCache();

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _favCol =>
      _db.collection('users').doc(_uid).collection('favorites');

  // 즐겨찾기 추가 (1순위.로컬, 2순위.Firestore 시도)
  Future<void> addFavorite(String recipeId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // 1순위.로컬 업데이트
    final current = _localCache.loadFavorites(uid);
    if (!current.contains(recipeId)) {
      current.add(recipeId);
      await _localCache.saveFavorites(uid, current);
    }

    // 2순위.Firestore 반영 시도 (실패해도 로컬 유지)
    try {
      await _favCol.doc(recipeId).set({"saved": true});
    } catch (e, st) {
    }
  }

  // 즐겨찾기 제거 (위와 동일)
  Future<void> removeFavorite(String recipeId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final uid = user.uid;

    // 1순위.로컬 업데이트
    final current = _localCache.loadFavorites(uid);
    current.remove(recipeId);
    await _localCache.saveFavorites(uid, current);

    // 2순위.Firestore 반영 시도
    try {
      await _favCol.doc(recipeId).delete();
    } catch (e, st) {
    }
  }

  // 즐겨찾기 전체 리스트 가져오기 (1순위.로컬, 2순위.Firestore 동기화)
  Future<List<String>> getFavoriteList() async {
    final user = _auth.currentUser;
    if (user == null) return [];
    final uid = user.uid;

    // 1순위.로컬 먼저 시도
    var list = _localCache.loadFavorites(uid);
    if (list.isNotEmpty) {
      return list;
    }

    // 2순위.Firestore 동기화 -> 로컬X -> Firestore에서 로컬로 저장
    try {
      final snapshot = await _favCol.get();
      list = snapshot.docs.map((doc) => doc.id).toList();
      await _localCache.saveFavorites(uid, list);
      return list;
    } catch (e, st) {
      return [];
    }
  }
}